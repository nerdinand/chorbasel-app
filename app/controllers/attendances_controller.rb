# frozen_string_literal: true

class AttendancesController < ApplicationController
  def create
    @attendance = authorize(Attendance.new(attendance_params))
    @attendance.calendar_event_id = params[:calendar_event_id]
    # TODO: check if this is still an ongoing event, return an error otherwise

    flash[:success] = if @attendance.save
                        t('.success')
                      else
                        t('.error')
                      end
    redirect_to dashboard_path
  end

  private

  def attendance_params
    params.require(:attendance).permit(:user_id, :status)
  end
end
