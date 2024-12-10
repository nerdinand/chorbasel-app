# frozen_string_literal: true

class InfoPolicy < ApplicationPolicy
  attr_reader :user, :info

  def initialize(user, info)
    super
    @user = user
    @info = info
  end

  def index?
    user.roles_wrapper.app?
  end

  def create?
    user.roles_wrapper.app?
  end

  def update?
    user.roles_wrapper.app?
  end
end
