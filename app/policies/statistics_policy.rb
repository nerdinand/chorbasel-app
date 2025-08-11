# frozen_string_literal: true

class StatisticsPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    super
    @user = user
  end

  def index?
    user.roles_wrapper.app? || user.roles_wrapper.choir_direction? || app.roles_wrapper.absences?
  end
end
