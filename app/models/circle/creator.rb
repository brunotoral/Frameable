class Circle
  class Creator
    attr_reader :frame, :circle, :errors

    def initialize(frame, circle)
      @frame = frame
      @circle = circle
      @errors = []
    end

    def save
      return false if invalid?

      circle.save!(validate: false)

      true
    end

    def invalid?
      !valid?
    end

    def valid?
      valid_circle? && wrapped_by_frame? && collision_free?
    end

    private

    def valid_circle?
      return true if circle.valid?

      errors << circle.errors.full_messages.to_sentence

      false
    end

    def wrapped_by_frame?
      return true if frame.wraps?(circle)

      errors << "must be fully inside frame boundaries"

      false
    end


    def collision_free?
      return true unless circle.overlaps_existing_circles?(frame.circles)

      errors << "collides with another existing circle"

      false
    end
  end
end
