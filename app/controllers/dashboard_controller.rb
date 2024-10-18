# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @calendar_events = CalendarEvent.next
  end
end
