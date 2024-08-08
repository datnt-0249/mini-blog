class Api::V1::RelationshipsController < Api::V1::BaseController
  before_action :logged_in_user, :find_user

  def create
    return if current_user.following.include? @user

    current_user.follow(@user)
    json_response nil, t("relationships.create.success")
  end

  def destroy
    current_user.unfollow @user

    json_response nil, t("relationships.destroy.success")
  end

  private

  def find_user
    @user = User.find params[:followed_id]
  end
end
