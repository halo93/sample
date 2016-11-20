class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :name, presence: true, length: {maximum: 50}
  validates :password, length: {minimum: 6}, presence: true, allow_nil: true
  has_secure_password
  before_save :downcase_email
  before_create :create_activation_digest

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
          BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def downcase_email
    email.downcase!
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    self.update_attributes activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def retrieve_activated_users
    User.select(:id, :name, :email, :created_at, :updated_at, :activated)
      .where(activated: true)
      .order(updated_at: :desc)
  end

  def password_reset_expired?
    reset_sent_at < 2.hour.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
      WHERE follower_id = :user_id"
    Micropost.order_by_updated_time.where "user_id IN (#{following_ids})
      OR user_id = :user_id", user_id: id
  end

  def follow another_user
    active_relationships.create followed_id: another_user.id
  end

  def unfollow another_user
    active_relationships.find_by(followed_id: another_user.id).destroy
  end

  def following? another_user
    following.include? another_user
  end

  private
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
