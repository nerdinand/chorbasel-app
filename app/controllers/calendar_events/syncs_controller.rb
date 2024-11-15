# frozen_string_literal: true

module CalendarEvents
  class SyncsController < ApplicationController
    def create
      authorize :calendar_sync, :create?

      CalendarSyncJob.perform_now

      flash.notice = t('.success')
      redirect_to dashboard_path
    end
  end
end
