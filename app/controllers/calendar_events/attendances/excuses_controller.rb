# frozen_string_literal: true

module CalendarEvents
  module Attendances
    class ExcusesController < ApplicationController
      def new
        calendar_event = CalendarEvent.find(params[:calendar_event_id])
        @attendance = authorize Attendance.new(calendar_event:)
      end

      def create
        @attendance = authorize Attendance.find_or_initialize_by(
          calendar_event: CalendarEvent.find(params[:calendar_event_id]),
          user: current_user
        )

        if @attendance.update(attendance_params)
          flash[:success] = t('.success')
        else
          flash[:error] = t('.error')
        end
        redirect_to dashboard_path
      end

      private

      def attendance_params
        {
          status: Attendance::STATUS_EXCUSE_REQUESTED,
          remarks: "#{current_user.display_name}:\n" + params[:attendance][:remarks].lines.map do |line|
            "> #{line}"
          end.join
        }
      end
    end
  end
end
