class CirclesController < ApplicationController
  before_action :set_circle, except: :index

  def index
    @circles = paginate Circle.filtered(filters: filter_params)
  end

  def update
    @updater = Circle::Updater.new(@circle, circle_params)

    if @updater.save
      @circle = @updater.circle
      render status: :ok
    else
      message = @updater.errors.to_sentence
      render json: { error: "Record Invalid", message: }, status: :unprocessable_entity
    end
  end

  def destroy
    @circle.destroy
  end

  private

  def filter_params
    fp = params.permit(:frame_id, :center_x, :center_y, :radius).to_h

    {
      frame_id: fp[:frame_id],
      area: {
        center_x: fp[:center_x],
        center_y: fp[:center_y],
        radius: fp[:radius]
      }.compact_blank.presence
    }.compact_blank
  end

  def circle_params
    params.require(:circle).permit(:center_y, :center_x, :radius)
  end

  def set_circle
    @circle ||= Circle.find params[:id]
  end
end
