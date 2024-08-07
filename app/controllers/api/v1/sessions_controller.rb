class Api::V1::SessionsController < Api::V1::BaseController
  def create
    user = User.find_by! email: params.dig(:session, :email)&.downcase

    unless user&.authenticate(params.dig(:session, :password))
      raise AuthenticationError
    end

    reset_session
    log_in user
    json_response user, t("sessions.create.success"), :created
  end
end
