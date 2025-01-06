# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers
  include Pundit::Authorization

  helper_method :current_user, :logged_in?

  before_action :require_user!

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    return if current_user

    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path
  end

  def logged_in?
    current_user.present?
  end
end
