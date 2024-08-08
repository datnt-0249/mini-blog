class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_in_valid
  rescue_from Zip::Error, with: :invalid_file_format

  before_action :set_locale
  include SessionsHelper
  include Pagy::Backend

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".required_login"
    redirect_to login_path, status: :see_other
  end

  def record_not_found
    flash[:warning] = t ".user_not_found"
    redirect_to root_path
  end

  def record_in_valid
    flash[:warning] = t ".user_not_found"
    redirect_to root_path
  end

  def invalid_file_format exception
    flash[:danger] = exception
    redirect_to root_path
  end
end
