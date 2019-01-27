# frozen_string_literal: true

require 'test_helper'

class FavoriteMicropostTest < ActiveSupport::TestCase
  def setup
    @favorite = FavoriteMicropost.new(micropost_id: microposts(:orange).id,
                                      subscriber_id: users(:michael).id)
  end

  test 'should be valid?' do
    assert @favorite.valid?
  end

  test 'should be require micropost_id' do
    @favorite.micropost_id = nil
    assert_not @favorite.valid?
  end

  test 'should be require subscriber_id' do
    @favorite.subscriber_id = nil
    assert_not @favorite.valid?
  end
end
