class DirectMessage < ApplicationRecord
  belongs_to :message_room
  validates :content, presence: true
end
