# frozen_string_literal: true

require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'micropost interface' do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type="file"]'

    # Invalid submit
    post microposts_path, params: { micropost: { content: '' } }
    assert_select 'div#error_explanation'

    # Valid submit
    content = "@#{@other_user.identity_name}
     This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,
                                                   picture: picture } }
    end
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_equal @other_user.id, first_micropost.in_reply_to
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # Subscribe Micropost
    assert_select 'input.not-favorite'
    assert_difference 'FavoriteMicropost.count', 1 do
      post favorite_microposts_path, params: { micropost_id: first_micropost.id }
    end
    follow_redirect!
    assert_select 'input.favorite'
    assert_select 'div.favorite-counts'

    # Remove a micropost
    assert_select 'a', text: 'delete'
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # Access other person's profile(Confirm delete link isnot exist)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test 'micropost sidebar count' do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # a user who donot post any microposts yet
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match '0 microposts', response.body
    other_user.microposts.create!(content: 'A micropost')
    get root_path
    assert_match '1 micropost', response.body
  end
end
