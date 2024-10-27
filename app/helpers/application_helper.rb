# frozen_string_literal: true

module ApplicationHelper
  def boolean_emoji(value)
    value ? '✅' : '❌'
  end

  def logo_path
    image_path(Rails.env.production? ? 'logo.webp' : 'logo-local.webp')
  end
end
