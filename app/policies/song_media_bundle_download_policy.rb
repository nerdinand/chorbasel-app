# frozen_string_literal: true

class SongMediaBundleDownloadPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    true
  end
end
