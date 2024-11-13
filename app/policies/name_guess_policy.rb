# frozen_string_literal: true

class NameGuessPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _record)
    super
    @user = user
  end

  def index?
    superpowers?
  end

  def show?
    superpowers?
  end

  def create?
    true
  end

  def update?
    superpowers?
  end

  def destroy?
    superpowers?
  end
end
