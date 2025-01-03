# frozen_string_literal: true

class StatisticsPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    super
    @user = user
  end

  def index?
    user.roles_wrapper.app?
  end
end
