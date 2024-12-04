# frozen_string_literal: true

class AttendancesController < ApplicationController
  include AttendanceTableBuilder

  def index
    @attendance_table = authorize AttendancesController.build_attendance_table(User.all)
    @excuse_requested_attendances = authorize Attendance.excuse_requested
  end

  def new
    user = User.find(params[:user_id])
    calendar_event = CalendarEvent.find(params[:calendar_event_id])

    @attendance = authorize Attendance.new(user:, calendar_event:, status: Attendance::STATUS_EXCUSED)
  end

  def edit
    @attendance = authorize(Attendance.find(params[:id])).tap do |attendance|
      attendance.status = Attendance::STATUS_EXCUSED
    end
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
