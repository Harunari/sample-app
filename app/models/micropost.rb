# frozen_string_literal: true

class Micropost < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc) }

  # @!method including_replies
  #   @!scope class
  #   @param [User]
  #   @return [ActiveRecord::Relation]
  scope :including_replies, ->(user) {
    where('in_reply_to IS NULL OR in_reply_to = :user_id', user_id: user.id)
  }

  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  # @return [String]
  # @return [nil] incase identity_name isnt exist or discrimination it, return nil
  def extract_identity_name
    content[/@(\w+)/, 1]
  end

  # @param [String]
  # @return [Boolean]
  def insert_reply_id_from(id_name)
    if id_name.present?
      self.in_reply_to = User.find_by(identity_name: id_name).id
    end
  end
end

private

# Validate size of uploaded image file
def picture_size
  errors.add(:picture, 'should be less than 5MB') if picture.size > 5.megabytes
end
