require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user1) {create(:user)}
  let(:user2) {create(:user)}
  let!(:private_post) {create(:post, status: :private, user: user1)}
  let!(:public_post) {create(:post, status: :public, user: user2)}

  shared_examples "validates presence of" do |attr|
    it { should validate_presence_of(attr)}
  end

  shared_examples "validates length of" do |attr, max_length, min_length|
    it { should validate_length_of(attr).is_at_most(max_length) } if max_length
    it { should validate_length_of(attr).is_at_least(min_length) } if min_length
  end

  describe "Validation" do
    context "Title" do
      include_examples "validates presence of", :title
      include_examples "validates length of", :title, Settings.digits.length_50, nil
    end

    context "Content" do
      include_examples "validates presence of", :content
      include_examples "validates length of", :content, Settings.digits.length_255, nil
    end
  end

  describe "Association" do
    it { should have_many(:likes).dependent(:destroy) }
    it { should belong_to(:user) }
  end

  describe "Method" do
    it "statuses i18n" do
      expect(described_class.statuses_i18n).to eq([
       ["Public", "public"],
       ["Private", "private"]
      ])
    end
  end

  describe "Scope" do
    it "newest" do
      expect(described_class.newest).to eq described_class.order(created_at: :desc)
    end

    it "filter by status" do
      expect(described_class.filter_by_status(:public)).to eq([public_post])
    end

    it "by user" do
      expect(described_class.by_users(user1)).to eq([private_post])
    end
  end
end
