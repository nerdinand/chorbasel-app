# frozen_string_literal: true

module CalendarEvents
  module Attendances
    class ExcusesController < ApplicationController
      def new
        calendar_event = CalendarEvent.find(params[:calendar_event_id])
        @attendance = authorize Attendance.new(calendar_event:, user: current_user)
        result = AttendanceRestrictionCheck.new(current_user, calendar_event).can_create_excuse

        return if result.success?

        flash.alert = t(".#{result.error_symbol}")
        redirect_back_or_to(dashboard_url)
      end

      def create
        calendar_event = CalendarEvent.find(params[:calendar_event_id])
        result = AttendanceRestrictionCheck.new(current_user, calendar_event).can_create_excuse

        if result.success?
          perform_create(calendar_event)
        else
          flash.alert = t(".#{result.error_symbol}")
          render :new, status: :unprocessable_entity
        end
      end

      def accept
        @attendance = authorize Attendance.find(params[:excuse_id])

        @attendance.accept!

        if @attendance.save
          flash.notice = t('.success')
          redirect_to attendances_path
        else
          flash.alert = t('.error')
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def perform_create(calendar_event) # rubocop:disable Metrics/MethodLength
        @attendance = authorize Attendance.find_or_initialize_by(
          calendar_event:,
          user: current_user
        )

        if update_attendance
          flash.notice = t('calendar_events.attendances.excuses.create.success')
          redirect_to dashboard_path
        else
          flash.alert = t('calendar_events.attendances.excuses.create.error')
          render :new, status: :unprocessable_entity
        end
      end

      def update_attendance
        if params[:attendance][:remarks].blank?
          @attendance.errors.add(:remarks,
                                 t('calendar_events.attendances.excuses.create.remark_blank_error'))
          return false
        end

        @attendance.update(attendance_params)
      end

      def attendance_params
        {
          status: Attendance::STATUS_EXCUSE_REQUESTED,
          remarks: params[:attendance][:remarks]
        }
      end
    end
  end
end
