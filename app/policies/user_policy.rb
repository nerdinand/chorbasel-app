# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :user, :user_to_modify

  def initialize(user, user_to_modify)
    super
    @user = user
    @user_to_modify = user_to_modify
  end

  def index?
    superpowers?
  end

  def show?
    true
  end

  def create?
    superpowers?
  end

  def update?
    superpowers? || user == user_to_modify
  end

  def admin_edit?
    superpowers?
  end

  def destroy?
    superpowers?
  end
end
