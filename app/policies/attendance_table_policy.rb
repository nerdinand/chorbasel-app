# frozen_string_literal: true

class AttendanceTablePolicy < ApplicationPolicy
  attr_reader :user, :attendance_table

  delegate :index?, to: :attendance_policy

  def initialize(user, attendance_table)
    super
    @user = user
    @attendance_table = attendance_table
  end

  private

  def attendance_policy
    Pundit.policy!(user, attendance_table.attendances)
  end
end
