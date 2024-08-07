class Api::V1::PostsController < Api::V1::BaseController
  before_action :find_post, :correct_user, only: %i(update)
  before_action :logged_in_user, only: %i(create following_posts)

  def create
    @post = current_user.posts.build post_params
    @post.save!
    json_response @post, t("posts.create.success"), :created
  end

  def update
    @post.update! params.dig(:post, :status)
    json_response @post, t("posts.update.success")
  end

  def following_posts
    @post = Post.by_users(current_user.following)
                .filter_by_status(:public)
                .newest
    @pagy, @posts = pagy(@post, limit: Settings.digits.per_page_10)
    @pagination = pagy_metadata(@pagy)

    json_response({post: @post, pagination: @pagination},
                  messages: t("posts.index.success"))
  end

  private

  def post_params
    params.require(:post).permit(Post::UPDATABLE_ATTRS)
  end

  def find_post
    @post = Post.find params[:id]
  end

  def correct_user
    return if current_user? @post.user

    raise Forbidden
  end
end
