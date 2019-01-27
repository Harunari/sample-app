# frozen_string_literal: true

class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :favorites, class_name: 'FavoriteMicropost',
                       foreign_key: 'subscriber_id',
                       dependent: :destroy
  has_many :favorite_microposts, through: :favorites, source: :micropost
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :identity_name, presence: true,
                            length: { minimum: 3, maximum: 25 },
                            uniqueness: { case_sensitive: false }

  class << self
    # 渡された文字列のハッシュ値を返す
    # @param string [String] clear text
    # @return [String]
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # @return [String]
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # @param attribute [String] the attribute
  # @param token [String] the token
  # @return [Boolean]
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # @return [Boolean]
  def password_reset_expired?
    reset_sent_at < 2.hour.ago
  end

  # @return [Array<Micropost>]
  def feed
    following_ids = "SELECT followed_id FROM relationships
                    WHERE follower_id = :user_id"

    Micropost.including_replies(self).where("user_id IN (#{following_ids})
    OR user_id = :user_id
    OR in_reply_to = :user_id", user_id: id)
  end

  # @param other_user [User] the other user
  def follow(other_user)
    following << other_user
  end

  # @param other_user [User] the other user
  # @return [Boolean]
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # @param other_user [User] the other user
  # @return [Boolean]
  def following?(other_user)
    following.include?(other_user)
  end

  # @param micropost [Micropost] the micropost object
  def favorite(micropost)
    favorite_microposts << micropost
  end

  # @param micropost [Micropost] the micropost object
  # @return [Boolean]
  def unfavorite(micropost)
    favorites.find_by(micropost_id: micropost.id).destroy
  end

  # @param micropost [Micropost]
  # @return [Boolean]
  def favorite?(micropost)
    favorite_microposts.include?(micropost)
  end

  private

  # @return [String]
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
