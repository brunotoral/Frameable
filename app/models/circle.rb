class Circle < ApplicationRecord
  include Filterable

  belongs_to :frame, counter_cache: true

  validates :center_x, :center_y, presence: true, numericality: true
  validates :radius, presence: true, numericality: { greater_than: 0 }

  scope :filter_by_frame_id, ->(id) { where(frame_id: id) }
  scope :filter_by_area, ->(params = {}) do
    cx = params[:center_x]
    cy = params[:center_y]
    r  = params[:radius]

    unless cx.present? && cy.present? && r.present?
      raise ArgumentError, "Missing parameters: center_x, center_y and radius are required for area filter"
    end

    where(
      <<~SQL,
      POWER(center_x - :cx, 2) + POWER(center_y - :cy, 2)
      <= POWER(:r - radius, 2)
      SQL
      cx: cx.to_d, cy: cy.to_d, r: r.to_d
    )
  end

  def left_edge
    center_x - radius
  end

  def right_edge
    center_x + radius
  end

  def top_edge
    center_y - radius
  end

  def bottom_edge
    center_y + radius
  end

  def overlaps_existing_circles?(circles)
    circles.where(
      <<~SQL,
      POWER(center_x - :cx, 2) + POWER(center_y - :cy, 2)
      <= POWER(:r + radius, 2)
      SQL
      cx: center_x.to_d, cy: center_y.to_d, r: radius.to_d
    ).exists?
  end
end
