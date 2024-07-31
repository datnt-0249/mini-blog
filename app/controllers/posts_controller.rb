class PostsController < ApplicationController
  before_action :logged_in_user, except: %i(index)

  def index
    @pagy, @posts = pagy(Post.filter_by_status(:public).newest,
                         limit: Settings.digits.per_page_10)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build post_params
    if @post.save
      flash[:success] = t ".success"
      redirect_to posts_path
    else
      flash.now[:danger] = t ".invalid"
      render :new, status: :unprocessable_entity
    end
  end

  private
  def post_params
    params.require(:post).permit Post::UPDATABLE_ATTRS
  end
end
