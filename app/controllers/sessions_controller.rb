# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  before_action :require_unauth!, only: %i[new show]

  private

  def require_unauth!
    return unless current_user

    redirect_to('/', notice: 'You are already signed in.')
  end
end
