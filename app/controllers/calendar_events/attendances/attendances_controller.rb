# frozen_string_literal: true

module CalendarEvents
  module Attendances
    class AttendancesController < ApplicationController
      def create
        calendar_event = CalendarEvent.find(params[:calendar_event_id])

        if calendar_event.ongoing?
          perform_create(calendar_event)
        else
          flash[:error] = t('.error')
        end
        redirect_to dashboard_path
      end

      private

      def perform_create(calendar_event)
        @attendance = authorize Attendance.new(status: Attendance::STATUS_ATTENDED, user: current_user)
        @attendance.calendar_event = calendar_event

        if @attendance.save
          flash[:success] = t('.success')
        else
          flash[:error] = t('.error')
        end
      end
    end
  end
end
