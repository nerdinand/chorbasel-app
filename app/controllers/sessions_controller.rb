# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  skip_before_action :require_user!, except: %i[destroy] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :require_unauth!, only: %i[new show] # rubocop:disable Rails/LexicallyScopedActionFilter

  def update
    super

    # A bit of a hack: we can only set our success flash message if the super
    # call hasn't failed, e.g. because of a code that was used twice. The only
    # way to check that, that I've figured out is to check if flash[:alert] was
    # set.
    return if flash[:alert].present?

    flash.notice = t('.success', user_name: current_user.display_name)
  end

  private

  def require_unauth!
    return unless current_user

    redirect_to root_path
  end
end
