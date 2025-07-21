# frozen_string_literal: true

class AttendancePolicy < ApplicationPolicy
  attr_reader :user, :attendance

  def initialize(user, attendance)
    super
    @user = user
    @attendance = attendance
  end

  def index?
    managing?
  end

  def show?
    true
  end

  def create?
    managing? || attendance.user == user
  end

  def update?
    managing?
  end

  def destroy?
    managing?
  end

  def accept?
    managing?
  end

  private

  def managing?
    superpowers? || user.roles_wrapper.absences?
  end
end
