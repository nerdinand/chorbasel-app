# frozen_string_literal: true

class Info < ApplicationRecord
  KIND_NOTICE = 'notice'
  KIND_ALERT = 'alert'
  KINDS = [KIND_NOTICE, KIND_ALERT].freeze

  has_rich_text :content

  validates :title, :content, :kind, presence: true
  validates :kind, inclusion: KINDS

  scope :newest, -> { order(updated_at: :desc) }
  scope :active, -> { where(active: true) }
  scope :newest_active, -> { active.newest }
end
