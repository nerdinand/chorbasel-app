# frozen_string_literal: true

class CalendarEventPolicy < ApplicationPolicy
  attr_reader :user, :calendar_event

  def initialize(user, calendar_event)
    super
    @user = user
    @calendar_event = calendar_event
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
