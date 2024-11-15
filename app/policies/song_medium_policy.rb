# frozen_string_literal: true

class SongMediumPolicy < ApplicationPolicy
  attr_reader :user, :song_medium

  def initialize(user, song_medium)
    super
    @user = user
    @song_medium = song_medium
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
    superpowers?
  end
end
