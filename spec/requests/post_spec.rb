require 'rails_helper'
include SessionsHelper

RSpec.describe PostsController, type: :controller do
  let(:user) {create(:user)}
  let(:other_user) {create(:user)}
  let!(:posts) {create_list(:post, 15, user: user)}
  let!(:other_posts) {create_list(:post, 15, user: other_user)}

  shared_examples "when not correct user" do
    it "when not correct user" do
      log_in other_user
      get :edit, params: {id: posts.first.id}
      expect(response).to redirect_to root_path
    end
  end

  before do
    log_in user
  end

  describe "GET /index" do
    it "assigns @posts" do
      get :index
      expect(assigns(:posts).size).to eq(Settings.digits.per_page_10)
    end

    it "render index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "POST /create" do
    let(:invalid_params) {attributes_for(:post, title: "")}

    context "with valid params" do
      before do
        post :create, params:  {post: attributes_for(:post)}
      end

      it "create a new post" do
        expect {
          post :create,
          params: {post: attributes_for(:post)}
        }.to change(Post, :count).by(1)
      end

      it "redirect to posts path" do
        expect(response).to redirect_to posts_path
      end

      it "display flash success" do
        expect(flash[:success]).to eq I18n.t("posts.create.success")
      end
    end

    context "with invalid params" do
      it "display flash failed" do
        post :create, params: {post: invalid_params}
        expect(flash[:danger]).to eq I18n.t("posts.create.invalid")
      end
    end
  end

  describe "GET /edit" do
    include_examples "when not correct user"
  end

  describe "PATCH /update" do
    include_examples "when not correct user"

    let(:invalid_params) {attributes_for(:post, title: "")}
    let(:post) {posts.first}

    context "with valid params" do
      it "display flash success" do
        patch :update, params: {id: post.id, post: attributes_for(:post)}
        expect(flash[:success]).to eq I18n.t("posts.update.success")
      end

      it "redirect to user path" do
        patch :update, params: {id: post.id, post: attributes_for(:post)}
        expect(response).to redirect_to user_path(user)
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: {id: post.id, post: invalid_params}
      end

      it "display flash error" do
        expect(flash[:failed]).to eq I18n.t("posts.update.failed")
      end

      it "render edit template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET /following-posts" do
    before do
      user.follow(other_user)
    end

    it "assigns @posts" do
      get :following_posts
      expect(assigns(:posts)).to eq other_user.posts.newest.filter_by_status(:public).limit(Settings.digits.per_page_10)
    end

    it "render index template" do
      get :following_posts
      expect(response).to render_template("following_posts")
    end
  end

  describe "DELETE /destroy" do
    include_examples "when not correct user"
    let(:post) {posts.first}

    context "when delele success" do
      before do
        delete :destroy, params: {id: post.id}
      end

      it "display flash success" do
        expect(flash[:success]).to eq I18n.t("posts.destroy.success")
      end

      it "redirect to user path" do
        expect(response).to redirect_to user_path(user)
      end
    end

    context "when delete failed" do
      before do
        allow_any_instance_of(Post).to receive(:destroy).and_return(false)
        delete :destroy, params: {id: post.id}
      end

      it "display flash failed" do
        expect(flash[:failed]).to eq I18n.t("posts.destroy.failed")
      end

      it "redirect to user path" do
        expect(response).to redirect_to user_path(user)
      end
    end
  end
end
