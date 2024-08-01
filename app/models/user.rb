class User < ApplicationRecord
  UPDATABLE_ATTRS = %i(name email password password_confirmation).freeze
  has_many :posts, dependent: :destroy

  has_many :active_relationships, class_name: Relationship.name,
                                  foreign_key: :follower_id,
                                  dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
                                    foreign_key: :followed_id,
                                    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :email, format: {with: Settings.regexes.email},
                    presence: true,
                    length: {maximum: Settings.digits.length_255},
                    uniqueness: true
  validates :password, presence: true,
                       length: {minimum: Settings.digits.length_6}
  validates :name, presence: true,
                   length: {maximum: Settings.digits.length_50}

  has_secure_password

  scope :ordered_by_name, ->{order(name: :asc)}

  before_save :downcase_email

  def follow other_user
    following << other_user unless self == other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  private
  def downcase_email
    email.downcase!
  end
end
