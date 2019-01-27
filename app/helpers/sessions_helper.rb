# frozen_string_literal: true

module SessionsHelper
  # 渡されたユーザーでログインする
  # @ param user [User]
  def log_in(user)
    session[:user_id] = user.id
  end

  # @ param user [User]
  def remember(user)
    user.remember
    cp = cookies.permanent
    cp.signed[:user_id] = user.id
    cp[:remember_token] = user.remember_token
  end

  # @ param user [User]
  # @return [Boolean]
  def current_user?(user)
    user == current_user
  end

  # 現在ログイン中のユーザを返す(いる場合)
  # @return [User]
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # @return [Boolean]
  def logged_in?
    current_user.present?
  end

  # @ param user [User]
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
