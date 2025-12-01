# frozen_string_literal: true

class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform
    calendar_url = Rails.application.credentials[:calendar_url]

    if calendar_url.nil?
      Rails.logger.warn ':calendar_url is not defined in credentials, skipping CalendarSyncJob'
      return
    end

    CalendarSyncService.new(calendar_url).perform!
  end
end
