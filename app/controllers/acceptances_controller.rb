# frozen_string_literal: true

class AcceptancesController < ApplicationController
  def create
    @attendance = authorize Attendance.find(params[:attendance_id])

    if @attendance.update(status: Attendance::STATUS_EXCUSED)
      flash.notice = t('.success')
    else
      flash.alert = t('.error')
    end

    redirect_to attendances_path
  end
end
