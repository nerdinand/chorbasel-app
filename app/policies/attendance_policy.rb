# frozen_string_literal: true

class AttendancePolicy < ApplicationPolicy
  attr_reader :user, :attendance

  def initialize(user, attendance)
    super
    @user = user
    @attendance = attendance
  end

  def index?
    superpowers? || user.roles_wrapper.absences?
  end

  def show?
    true
  end

  def create?
    modification_allowed?
  end

  def update?
    modification_allowed?
  end

  def destroy?
    modification_allowed?
  end

  private

  def modification_allowed?
    superpowers? || user.roles_wrapper.absences? || attendance.user == user
  end
end
