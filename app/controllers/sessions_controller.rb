# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  skip_before_action :require_user!, except: %i[destroy] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :require_unauth!, only: %i[new show] # rubocop:disable Rails/LexicallyScopedActionFilter

  def update
    return unless super

    flash[:success] = t('.success', user_name: current_user.display_name)
  end

  private

  def require_unauth!
    return unless current_user

    redirect_to root_path
  end
end
