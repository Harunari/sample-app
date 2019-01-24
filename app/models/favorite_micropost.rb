class FavoriteMicropost < ApplicationRecord
  belongs_to :micropost
  belongs_to :subscriber, class_name: 'User'
  validates :micropost_id, presence: true
  validates :subscriber_id, presence: true
end
