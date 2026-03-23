# frozen_string_literal: true

module CalendarEvents
  class AttendanceCountsController < ApplicationController
    def show
      @status = params[:status]
      calendar_event = CalendarEvent.find(params[:calendar_event_id])

      if @status.in? Attendance::STATUSES
        @count = AttendanceCount.new(calendar_event, @status).count
      else
        render status: :bad_request
      end
    end
  end
end
