# frozen_string_literal: true

class MessageRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  has_many :direct_messages

  default_scope -> { order(updated_at: :desc) }

  validates :sender_id, presence: true, uniqueness: { scope: :receiver_id }
  validates :receiver_id, presence: true
end
