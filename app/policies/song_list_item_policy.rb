# frozen_string_literal: true

class SongListItemPolicy < ApplicationPolicy
  attr_reader :user, :song_list_item

  def initialize(user, song_list_item)
    super
    @user = user
    @song_list_item = song_list_item
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
