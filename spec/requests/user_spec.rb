require 'rails_helper'
include SessionsHelper

RSpec.describe UsersController, type: :controller do
  let(:user) {create(:user)}
  let(:users) {create_list(:user, 5)}
  let!(:posts) {create_list(:post, 15, user: user)}

  before do
    log_in user
  end

  describe "GET /index" do
    context "when search params not present" do
      it "assigns @user" do
        get :index
        expect(assigns(:users)).to eq([user])
      end

      it "render index template" do
        get :index
        expect(response).to  render_template("index")
      end
    end

    context "when search params present" do
      it "search by user name" do
        get :index, params: {q: { name_cont: users.first.name }}
        expect(assigns(:users)).to eq([users.first])
      end

      it "search by email" do
        get :index, params: {q: { email_cont: users.first.email }}
        expect(assigns(:users)).to eq([users.first])
      end

      it "search by created at" do
        users.first.update_column(:created_at, 5.days.ago)
        from_date = 6.days.ago
        to_date = 3.days.ago

        get :index, params: { q: { created_at_gteq: from_date, created_at_lteq: to_date }}
        expect(assigns(:users)).to eq([users.first])
      end
    end
  end

  describe "POST /create" do
    let(:invalid_params) {attributes_for(:user, name: "")}

    context "with valid params" do
      before do
        post :create, params: {user: attributes_for(:user)}
      end

      it "create a new user" do
        expect {
          post :create,
          params: {user: attributes_for(:user)}
        }.to change(User, :count).by(1)
      end

      it "redirect to user path" do
        expect(response).to redirect_to user_path(User.last)
      end

      it "display flash success" do
        expect(flash[:success]).to eq I18n.t("users.create.success")
      end
    end

    context "with invalid params" do
      before do
        post :create, params: {user: invalid_params}
      end

      it "display flash failed" do
        expect(flash[:danger]).to eq I18n.t("users.create.failed")
      end

      it "render new template" do
        expect(response).to render_template ("new")
      end
    end
  end

  describe "GET /show" do
    context "when user not found" do
      before do
        get :show, params: {id: -1}
      end

      it "redirect to root path" do
        expect(response).to redirect_to root_path
      end

      it "display flash danger" do
        expect(flash[:warning]).to  eq I18n.t("users.show.user_not_found")
      end
    end

    context "when user found" do
      before do
        get :show, params: {id: user.id}
      end

      it "render show template" do
        expect(response).to render_template("show")
      end

      it "assigns @posts" do
        expect(assigns(:posts).size).to eq(Settings.digits.per_page_10)
      end
    end
  end
end
