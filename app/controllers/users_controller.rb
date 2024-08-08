class UsersController < ApplicationController
  before_action :find_user, only: %i(show)
  before_action :logged_in_user, only: %i(show)

  def index
    @pagy, @users = pagy(User.ordered_by_name,
                         limit: Settings.digits.per_page_10)
  end

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
    if current_user? @user
      @pagy, @posts = pagy(@user.posts.newest,
                           limit: Settings.digits.per_page_10)
    else
      @pagy, @posts = pagy(@user.posts.filter_by_status(:public).newest,
                           limit: Settings.digits.per_page_10)
    end
  end

  private
  def user_params
    params.require(:user).permit User::UPDATABLE_ATTRS
  end

  def find_user
    @user = User.find params[:id]
  end
end
