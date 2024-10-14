# frozen_string_literal: true

module ApplicationHelper
  def logo_path
    image_path(Rails.env.production? ? 'logo.webp' : 'logo-local.png')
  end

  def logged_in?
    true
  end
end
