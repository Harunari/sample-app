# frozen_string_literal: true

module ApplicationHelper
  # ページごとの完全なタイトルを返します
  # @param [String] Page Tite
  # @return [String] Return completion title
  def full_title(page_title = '')
    base_title = 'Ruby on Rails Tutorial Sample App'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  # params [User]
  # return [String]
  def full_name(user)
    "#{user.name}@#{user.identity_name}"
  end
end
