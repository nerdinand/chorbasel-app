# frozen_string_literal: true

class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform
    CalendarSyncService.new.perform!
  end
end
