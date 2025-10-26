class Frame
  class Creator
    attr_reader :frame, :errors

    def initialize(frame)
      @frame = frame
      @errors = []
    end

    def save
      return false if invalid?

      frame.save!(validate: false)
    end

    def invalid?
      !valid?
    end

    def valid?
      frame_valid? && collision_free?
    end

    private

    def frame_valid?
      return true if frame.valid?

      errors << frame.errors.full_messages.to_sentence

      false
    end

    def collision_free?
      return true unless frame.collides_with_existing_frame?

      errors << "collides with another existing frame"

      false
    end
  end
end
