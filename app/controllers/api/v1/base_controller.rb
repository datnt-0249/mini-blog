class Api::V1::BaseController < ApplicationController
  include Pagy::Backend
  include Api::ApiException::Handler

  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ArgumentError, with: :handle_error
  rescue_from Forbidden, with: :handle_error
  rescue_from AuthenticationError, with: :handle_error

  private

  def json_response object = {}, message = "", status = :ok
    render json: {data: object, message:}, status:
  end

  def logged_in_user
    return if logged_in?

    store_location
    render json: {errors: [t("users.required_login")]}, status: :unauthorized
  end

  def handle_record_not_found exception
    render json: {errors: [exception.message]}, status: :not_found
  end

  def handle_record_invalid exception
    render json: {errors: [exception.message]}, status: :unprocessable_entity
  end

  def handle_argument_invalid exception
    render json: {errors: [exception.message]}, status: :unprocessable_entity
  end

  def handle_error exception
    render json: {errors: [exception.message]}, status: exception.status_code
  end
end
