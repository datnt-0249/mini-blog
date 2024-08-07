require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {build(:user)}
  let(:user1) {create(:user)}
  let(:user2) {create(:user)}

  shared_examples "validates presence of" do |attr|
    it { should validate_presence_of(attr)}
  end

  shared_examples "validates length of" do |attr, max_length, min_length|
    it { should validate_length_of(attr).is_at_most(max_length) } if max_length
    it { should validate_length_of(attr).is_at_least(min_length) } if min_length
  end

  shared_examples "validates uniqueness_of" do |attr|
    it { should validate_presence_of(attr) }
  end

  describe "Validation" do
    context "Name" do
      include_examples "validates presence of", :name
      include_examples "validates length of", :name, Settings.digits.length_50, nil
    end

    context "Password" do
      include_examples "validates presence of", :password
      include_examples "validates length of", :password, nil, Settings.digits.length_6
    end

    context "Email" do
      include_examples "validates presence of", :email
      include_examples "validates length of", :email, Settings.digits.length_255, nil
      include_examples "validates uniqueness_of", :email

      it { should allow_value("test@gmail.com").for(:email) }
    end
  end

  describe "Association" do
    it { should have_many(:posts) }
    it { should have_many(:liked_posts).through(:likes).source(:post) }
    it { should have_many(:following).through(:active_relationships).source(:followed) }
    it { should have_many(:followers).through(:passive_relationships).source(:follower) }
  end

  describe "Method" do
    it "downcase email before save" do
      user.email = "TEST@gmail.com"
      user.send(:downcase_email)
      expect(user.email).to eq("test@gmail.com")
    end

    context "follow user" do
      it "follow other user" do
        user1.follow user2
        expect(user1.following).to include(user2)
      end

      it "follow self" do
        user1.follow user1 do
          expect(user1.following).not_to include(user2)
        end
      end
    end

    it "unfollow user" do
      user1.unfollow user2 do
        expect(user1.following).not_to include(user2)
      end
    end
  end

  describe "Scope" do
    it "ordered by name" do
      expect(described_class.ordered_by_name).to eq([user1, user2].sort_by(&:name))
    end
  end
end
