# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @calendar_events = CalendarEvent.next
    @attendances = CalendarEvent.ongoing.map do |calendar_event|
      Attendance.find_or_initialize_by(user: current_user, calendar_event:).tap do |attendance|
        attendance.status = Attendance::STATUS_ATTENDED
      end
    end
  end
end
