# frozen_string_literal: true

class CalendarEventsController < ApplicationController
  def show
    @calendar_event = authorize(CalendarEvent.find(params[:id]))
  end
end
