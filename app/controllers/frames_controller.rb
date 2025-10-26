class FramesController < ApplicationController
  before_action :set_frame, except: %i[create index]

  def index
    @frames = paginate Frame.includes(:highest_circle, :lowest_circle, :leftmost_circle, :rightmost_circle).all
  end

  def show; end

  def create
    @frame = Frame.build(frame_params)
    @creator = Frame::Creator.new(@frame)

    if @creator.save
      render status: :created
    else
      message = @creator.errors.to_sentence
      render json: { error: "Record Invalid", message: }, status: :unprocessable_entity
    end
  end

  def update
    @frame.update!(frame_params)
  end

  def destroy
    @frame.destroy
  end

  private

  def frame_params
    params.require(:frame).permit(:center_x, :center_y, :width, :height)
  end

  def set_frame
    @frame ||= Frame.find params[:id]
  end
end
