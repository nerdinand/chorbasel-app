# frozen_string_literal: true

class CalendarSyncPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    super
    @user = user
  end

  def create?
    superpowers?
  end
end
