class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate(params.dig(:session, :password))
      forwarding_url = session[:forwarding_url]
      reset_session
      log_in user
      redirect_to forwarding_url || user
    else
      flash.now[:danger] = t ".invalid"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end
end
