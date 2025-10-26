class Circle
  class Updater
    attr_reader :circle, :params, :errors

    def initialize(circle, params)
      @circle = circle
      @params = params.to_hash
      @errors= []
    end

    def save
      return false if invalid?

      circle.update!(params)

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
      return true if spy.valid?

      errors << spy.errors.full_messages.to_sentence

      false
    end

    def wrapped_by_frame?
      return true if frame.wraps?(spy)

      errors << "must be fully inside frame boundaries"

      false
    end


    def collision_free?
      return true unless spy.overlaps_existing_circles?(frame.circles.where.not(id: circle.id))

      errors << "collides with another existing circle"

      false
    end

    def spy
      @spy ||= @circle.dup

      @spy.assign_attributes(params)

      @spy
    end

    delegate :frame, to: :circle
  end
end
