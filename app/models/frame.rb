class Frame < ApplicationRecord
  has_many :circles
  has_one :highest_circle, -> { order(center_y: :desc) }, class_name: "Circle"
  has_one :lowest_circle, -> { order(center_y: :asc) }, class_name: "Circle"
  has_one :leftmost_circle, -> { order(center_x: :asc) }, class_name: "Circle"
  has_one :rightmost_circle, -> { order(center_x: :desc) }, class_name: "Circle"

  validates :center_x, :center_y, presence: true, numericality: true
  validates :height, :width, presence: true, numericality: { greater_than: 0 }


  def left_edge
    center_x - (width / half)
  end

  def right_edge
    center_x + (width / half)
  end

  def top_edge
    center_y - (height / half)
  end

  def bottom_edge
    center_y + (height / half)
  end

  def wraps?(circle)
    circle.left_edge >= left_edge &&
      circle.right_edge <= right_edge &&
      circle.top_edge >= top_edge &&
      circle.bottom_edge <= bottom_edge
  end

  def collides_with_existing_frame?
    left_edge_val   = left_edge
    right_edge_val  = right_edge
    top_edge_val    = top_edge
    bottom_edge_val = bottom_edge

    scope = Frame.all
    scope = scope.where.not(id: id) if persisted?

    collision_clause = <<-SQL
      ( (center_x + (width / 2.0)) >= :left_edge ) AND
      ( (center_x - (width / 2.0)) <= :right_edge ) AND

      ( (center_y + (height / 2.0)) >= :top_edge ) AND
      ( (center_y - (height / 2.0)) <= :bottom_edge )
    SQL

    scope.where(collision_clause,
      left_edge:,
      right_edge:,
      top_edge:,
      bottom_edge:
    ).exists?
  end

  private

  def half
    @half ||= BigDecimal(2)
  end
end
