# frozen_string_literal: true

module Attendances
  class QuickActionsController < ApplicationController
    def create
      attendance = authorize Attendance.new(attendance_params)

      if attendance.save
        quick_action_success_response(attendance)
      else
        quick_action_error_response(attendance)
      end
    end

    def update
      attendance = authorize Attendance.find(params[:attendance_id])

      if attendance.update(attendance_params)
        quick_action_success_response(attendance)
      else
        quick_action_error_response(attendance)
      end
    end

    private

    def attendance_params
      params.expect(attendance: %i[user_id calendar_event_id status remarks])
    end

    def quick_action_success_response(attendance)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            quick_action_response_remove_row(attendance),
            quick_action_response_append_row(attendance)
          ] + quick_action_replace_status_counts(attendance.calendar_event)
        end
      end
    end

    def quick_action_error_response(attendance)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "attendance-row-user-#{attendance.user.id}", partial: 'errors', locals: { model: attendance }
            )
          ], status: :bad_request
        end
      end
    end

    def quick_action_response_remove_row(attendance)
      turbo_stream.remove("attendance-row-user-#{attendance.user.id}")
    end

    def quick_action_response_append_row(attendance)
      status = attendance.status
      turbo_stream.append(
        "attendances-#{status}",
        partial: 'calendar_events/attendance_row',
        locals: { attendance:, status: }
      )
    end

    def quick_action_replace_status_counts(calendar_event)
      Attendance::STATUSES.map do |status|
        count = AttendanceCount.new(calendar_event, status).count
        turbo_stream.replace(
          "attendance-count-#{status}",
          partial: 'calendar_events/attendance_counts/attendance_count', locals: { count:, status: }
        )
      end
    end
  end
end
