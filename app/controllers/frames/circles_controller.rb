module Frames
  class CirclesController < ApplicationController
    def create
      @frame = Frame.find params[:frame_id]
      @circle = @frame.circles.build(circle_params)
      @creator = Circle::Creator.new(@frame, @circle)

      if @creator.save
        @circle = @creator.circle
        render :create, status: :created
      else
        message = @creator.errors.to_sentence
        render json: { error: "Record Invalid", message: }, status: :unprocessable_entity
      end
    end

    private

    def circle_params
      params.require(:circle).permit(:center_y, :center_x, :radius)
    end
  end
end
