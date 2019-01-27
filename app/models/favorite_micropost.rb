class FavoriteMicropost < ApplicationRecord
  belongs_to :micropost
  belongs_to :subscriber, class_name: 'User'
  validates :micropost_id, presence: true
  validates :subscriber_id, presence: true

  # @return [Micropost]
  def subscribed_post
    Micropost.find_by(id: micropost_id)
  end

  # @return [User]
  def subscriber
    User.find_by(id: subscriber_id)
  end
end
