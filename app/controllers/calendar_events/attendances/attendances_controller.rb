# frozen_string_literal: true

module CalendarEvents
  module Attendances
    class AttendancesController < ApplicationController
      def create
        calendar_event = CalendarEvent.find(params[:calendar_event_id])

        result = AttendanceRestrictionCheck.new(current_user, calendar_event).can_create_signup

        if result.success?
          perform_create(calendar_event)
        else
          flash.alert = t(".#{result.error_symbol}")
        end
        redirect_to dashboard_path
      end

      private

      def perform_create(calendar_event)
        @attendance = authorize Attendance.new(status: Attendance::STATUS_ATTENDED, user: current_user)
        @attendance.calendar_event = calendar_event

        if @attendance.save
          flash.notice = t('calendar_events.attendances.attendances.create.success')
        else
          flash.alert = t('calendar_events.attendances.attendances.create.error')
        end
      end
    end
  end
end
