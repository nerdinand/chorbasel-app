# frozen_string_literal: true

class SongListPolicy < ApplicationPolicy
  attr_reader :user, :song_list

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.roles_wrapper.app? || user.roles_wrapper.choir_direction?
        scope.all
      else
        scope.active
      end
    end

    private

    attr_reader :user, :scope
  end

  def initialize(user, song_list)
    super
    @user = user
    @song_list = song_list
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
