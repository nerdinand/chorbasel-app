# frozen_string_literal: true

class AttendancesController < ApplicationController
  def index
    @attendance_pagination = AttendancePagination.new(params[:from], params[:to])
    @attendance_table = build_attendance_table
    @excuse_requested_attendances = Attendance.excuse_requested
  end

  def new
    user = User.find(params[:user_id])
    calendar_event = CalendarEvent.find(params[:calendar_event_id])

    @attendance = authorize Attendance.new(user:, calendar_event:, status: Attendance::STATUS_EXCUSED)
  end

  def edit
    @attendance = authorize Attendance.find(params[:id])
  end

  def create
    @attendance = authorize Attendance.new(attendance_params)

    if @attendance.save
      flash.notice = t('.success')
      redirect_to attendances_path
    else
      flash.alert = t('.error')
      render :new, status: :unprocessable_content
    end
  end

  def update
    @attendance = authorize Attendance.find(params[:id])

    if @attendance.update(attendance_params)
      flash.notice = t('.success')
      redirect_to attendances_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_content
    end
  end

  def quick_create
    attendance = authorize Attendance.new(attendance_params)

    if attendance.save
      quick_action_success_response(attendance)
    else
      quick_action_error_response(attendance)
    end
  end

  def quick_update
    attendance = authorize Attendance.find(params[:attendance_id])

    if attendance.update(attendance_params)
      quick_action_success_response(attendance)
    else
      quick_action_error_response(attendance)
    end
  end

  private

  def build_attendance_table
    calendar_events = CalendarEvent.where(starts_at: @attendance_pagination.current_range)
    users = User.ordered_by_register.user_status_during_time(
      UserStatus::STATUS_ACTIVE,
      calendar_events.first.starts_at,
      calendar_events.last.starts_at
    )
    attendances = authorize Attendance.where(user: users).where(calendar_event: calendar_events)
    AttendanceTable.new(attendances, users, calendar_events)
  end

  def attendance_params
    params.expect(attendance: %i[user_id calendar_event_id status remarks])
  end

  def quick_action_success_response(attendance)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          quick_action_response_remove_row(attendance),
          quick_action_response_append_row(attendance)
        ]
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
        ]
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
end
