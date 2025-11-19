# frozen_string_literal: true

class ProgramPolicy < ApplicationPolicy
  attr_reader :user, :program

  def initialize(user, program)
    super
    @user = user
    @program = program
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    song_management?
  end

  def update?
    song_management?
  end

  def destroy?
    song_management?
  end

  private

  def song_management?
    superpowers? || super
  end
end
