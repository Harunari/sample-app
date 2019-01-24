# frozen_string_literal: true

class Micropost < ApplicationRecord
  belongs_to :user
  has_many :favorites, class_name: 'FavoriteMicropost', dependent: :destroy
  has_many :subscribers, through: :favorites, source: :subscriber
  before_validation :set_reply_id_from_content

  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  #   @param user [User] the user object
  #   @return [ActiveRecord::Relation]
  def self.including_replies(user)
    where(in_reply_to: [user.id, nil]).or(Micropost.where(user_id: user.id))
  end

  def set_reply_id_from_content
    id_name = content[/@(\w+)/, 1]
    addressed_user = User.find_by(identity_name: id_name)
    if addressed_user.present?
      self.in_reply_to = addressed_user.id
    else
      self.in_reply_to = nil
    end
  end
end

private

# Validate size of uploaded image file
def picture_size
  errors.add(:picture, 'should be less than 5MB') if picture.size > 5.megabytes
end
