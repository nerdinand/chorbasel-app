# frozen_string_literal: true

class AttendancesController < ApplicationController
  EVENTS_FROM = 1.month
  EVENTS_TO = 2.months

  def index
    users = User.all
    calendar_events = CalendarEvent.where(starts_at: EVENTS_FROM.ago..EVENTS_TO.from_now)
    attendances = authorize Attendance.where(user: users).where(calendar_event: calendar_events)
    @attendance_table = AttendanceTable.new(attendances, users, calendar_events)
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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @attendance = authorize Attendance.find(params[:id])

    if @attendance.update(attendance_params)
      flash.notice = t('.success')
      redirect_to attendances_path
    else
      flash.alert = t('.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:user_id, :calendar_event_id, :status, :remarks)
  end
end
