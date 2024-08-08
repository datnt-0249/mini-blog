class PostsController < ApplicationController
  before_action :find_post, :correct_user, only: %i(edit update destroy)
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

  def edit; end

  def update
    if @post.update post_params
      flash[:success] = t ".success"
      redirect_to @post.user
    else
      flash.now[:failed] = t ".failed"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      flash[:success] = t ".success"
    else
      flash[:failed] = t ".failed"
    end
    redirect_to @post.user
  end

  def following_posts
    @post = Post.by_users(current_user.following)
                .filter_by_status(:public)
                .newest
    @pagy, @posts = pagy(@post, limit: Settings.digits.per_page_10)
  end

  def export
    @posts = Post.all
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def import
    column_mapping = {
      "Title" => :title,
      "Content" => :content,
      "Status" => :status
    }

    validate_file params[:file]
    xlsx = Roo::Excelx.new(params[:file])
    sheet = xlsx.sheet(0)
    headers = sheet.row(1)
    header_mapping = headers.map{|header| column_mapping[header]}

    read_sheet header_mapping
  end

  private
  def post_params
    params.require(:post).permit Post::UPDATABLE_ATTRS
  end

  def find_post
    @post = Post.find_by id: params[:id]
    return if @post

    flash[:warning] = t ".post_not_found"
    redirect_to root_path
  end

  def correct_user
    redirect_to root_path, status: :see_other unless current_user? @post.user
  end

  def read_sheet header_mapping
    (Settings.import.header_row..sheet.last_row).each do |row_index|
      row = Hash[[header_mapping, sheet.row(row_index)].transpose]
      next if row_hash.values.all?(&:nil?)

      @post = current_user.posts.build row

      @post.save!
      flash[:success] = t ".success"
    end
  end

  def validate_file file
    ext = File.extname(file.original_filename)
    return if [".xls", "xlsx"].include? ext

    raise Zip::Error, t(".invalid_file")
  end
end
