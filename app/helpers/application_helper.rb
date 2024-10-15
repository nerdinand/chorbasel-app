# frozen_string_literal: true

module ApplicationHelper
  def logo_path
    image_path(Rails.env.production? ? 'logo.webp' : 'logo-local.webp')
  end

  def logged_in?
    true
  end
end
