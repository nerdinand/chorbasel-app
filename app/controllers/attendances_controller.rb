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
    @attendance = authorize Attendance.new(attendance_params)

    if @attendance.save
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end
    redirect_to @attendance.calendar_event
  end

  def quick_update
    @attendance = authorize Attendance.find(params[:attendance_id])

    if @attendance.update(attendance_params)
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end
    redirect_to @attendance.calendar_event
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
end
