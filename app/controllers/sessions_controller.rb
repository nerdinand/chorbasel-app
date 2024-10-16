# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  skip_before_action :require_user!, except: %i[destroy] # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :require_unauth!, only: %i[new show] # rubocop:disable Rails/LexicallyScopedActionFilter

  private

  def require_unauth!
    return unless current_user

    redirect_to root_path
  end
end
