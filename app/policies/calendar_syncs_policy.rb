# frozen_string_literal: true

class CalendarSyncsPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    super
    @user = user
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    superpowers?
  end

  def update?
    superpowers?
  end

  def destroy?
    superpowers?
  end
end
