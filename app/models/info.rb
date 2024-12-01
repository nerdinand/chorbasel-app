# frozen_string_literal: true

class Info < ApplicationRecord
  KIND_NOTICE = 'notice'
  KIND_ALERT = 'alert'
  KINDS = [KIND_NOTICE, KIND_ALERT].freeze

  validates :title, :description, :kind, presence: true
  validates :kind, inclusion: KINDS

  scope :newest, -> { order(updated_at: :desc) }
  scope :active, -> { where(active: true) }
  scope :newest_active, -> { active.newest.first }
end
