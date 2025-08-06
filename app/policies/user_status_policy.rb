# frozen_string_literal: true

class UserStatusPolicy < ApplicationPolicy
  attr_reader :user, :user_status

  def initialize(user, user_status)
    super
    @user = user
    @user_status = user_status
  end

  def create?
    user_management?
  end

  def update?
    user_management? || user == user_to_modify
  end

  def admin_edit?
    user_management?
  end

  def destroy?
    user_management?
  end

  private

  def user_management?
    superpowers? || choir_life?
  end
end
