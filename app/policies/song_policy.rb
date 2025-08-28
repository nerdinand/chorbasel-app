# frozen_string_literal: true

class SongPolicy < ApplicationPolicy
  attr_reader :user, :song

  def initialize(user, song)
    super
    @user = user
    @song = song
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
