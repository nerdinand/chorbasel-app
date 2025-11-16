# frozen_string_literal: true

module ApplicationHelper
  def boolean_emoji(value)
    value ? '✅' : '❌'
  end

  def logo_path
    image_path(Rails.env.production? ? 'logo.webp' : 'logo-local.webp')
  end

  def app_version
    git_version = ENV['KAMAL_VERSION'] || `git rev-parse HEAD`
    git_version[...7]
  end

  def empty_icon
    tag.svg class: 'status-icon', width: 24, height: 24
  end
end
