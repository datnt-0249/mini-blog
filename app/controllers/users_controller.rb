class UsersController < ApplicationController
  before_action :set_user, only: %i(show)
  before_action :logged_in_user, only: %i(show)

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash.now[:danger] = t ".failed"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @pagy, @posts = pagy(@user.posts.newest,
                         items: Settings.digits.per_page_10)
  end

  private
  def user_params
    params.require(:user).permit User::UPDATABLE_ATTRS
  end

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t ".user_not_found"
    redirect_to root_path
  end
end
