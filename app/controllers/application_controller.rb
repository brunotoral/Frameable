class ApplicationController < ActionController::API
  include Pagy::Backend

  after_action { pagy_headers_merge(@pagy) if @pagy }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :show_record_errors
  rescue_from ActiveRecord::InvalidForeignKey, with: :frame_foreign_key_violation

  private

  def paginate(collection)
    @pagy, paginated_collection = pagy(collection)

    paginated_collection
  end

  def show_record_errors(exception)
    message =  exception.record.errors.full_messages.to_sentence

    render json: { error: "Record Invalid", message:  }, status: :unprocessable_entity
  end

  def record_not_found(exception)
    render json: { error: "Record Not Found", message: exception.message }, status: :not_found
  end

   def frame_foreign_key_violation(exception)
    render json: {
      error: "Deletion Failed",
      message: "This frame cannot be deleted because it is still referenced by other records (e.g., circles). Please delete associated records first."
     }, status: :conflict
  end
end
