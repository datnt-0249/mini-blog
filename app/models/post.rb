class Post < ApplicationRecord
  UPDATABLE_ATTRS = %i(title content status).freeze
  belongs_to :user
  has_many :likes, dependent: :destroy

  enum status: {public: 0, private: 1}, _suffix: :status

  validates :title, presence: true,
                    length: {maximum: Settings.digits.length_50}
  validates :content, presence: true,
                    length: {maximum: Settings.digits.length_255}

  scope :newest, ->{order(created_at: :desc)}
  scope :filter_by_status, ->(status){status.present? ? where(status:) : all}
  scope :by_users, ->(users){where(user_id: users)}

  class << self
    def statuses_i18n
      statuses.keys.map{|k| [I18n.t(".post.status.#{k}"), k]}
    end
  end
end
