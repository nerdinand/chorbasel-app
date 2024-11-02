# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :user, :user_to_modify

  def initialize(user, user_to_modify)
    super
    @user = user
    @user_to_modify = user_to_modify
  end

  def index?
    user_management?
  end

  def show?
    true
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
    superpowers? || choir_direction?
  end
end
