# frozen_string_literal: true

class User < ApplicationRecord
  include SpreadsheetArchitect

  before_save :set_canonical_register

  STATUS_ACTIVE = 'active'
  STATUS_PAUSED = 'paused'
  STATUS_INACTIVE = 'inactive'

  STATUSES = [STATUS_ACTIVE, STATUS_PAUSED, STATUS_INACTIVE].freeze

  INTERNATIONAL_PHONE_NUMBER_REGEX = /\A\+\d{11,13}\z/

  PROFILE_COMPLETENESS_FIELDS = %i[
    first_name
    last_name
    salutation
    street
    zip_code
    city
    phone_number
    birth_date
    register
  ].freeze

  has_one_attached :face_picture do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  has_one_attached :profile_picture do |attachable|
    attachable.variant :medium, resize_to_limit: [340, 520]
  end

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :roles, array: Roles::ROLES
  validates :phone_number, format: { with: INTERNATIONAL_PHONE_NUMBER_REGEX }, allow_blank: true
  validates :status, inclusion: STATUSES
  validates :register, inclusion: Register::Singer::REGISTERS, allow_blank: true
  validates :canonical_register, inclusion: Register::Singer::CANONICAL_REGISTERS, allow_blank: true

  has_many :attendances, dependent: :destroy

  passwordless_with :email

  scope :active, -> { where(status: STATUS_ACTIVE) }
  scope :sign_in_allowed, -> { where.not(status: STATUS_INACTIVE) }
  scope :ordered_by_register, -> { in_order_of(:register, Register::Singer::REGISTERS + [nil]) }

  def self.fetch_resource_for_passwordless(email)
    where('lower(email) = ?', email).sign_in_allowed.first
  end

  def roles_wrapper
    Roles.new(roles)
  end

  def full_name
    nick_name_part = ("\"#{nick_name}\"" if nick_name.present?)

    [first_name, nick_name_part, last_name].compact.join(' ')
  end

  def display_name
    nick_name.presence || first_name
  end

  def attendance_for(calendar_event)
    attendances.find_or_initialize_by(calendar_event:) do |attendance|
      attendance.status = Attendance::STATUS_UNKNOWN
    end
  end

  def profile_complete?
    PROFILE_COMPLETENESS_FIELDS.all? { |f| send(f).present? }
  end

  def human_status
    I18n.t("activerecord.attributes.user.enums.status.#{status}")
  end

  def register_object
    Register::Singer.new(register)
  end

  def human_register
    return nil if register.blank?

    I18n.t("activerecord.attributes.user.enums.register.#{register}")
  end

  def birth_date_this_year
    birth_date.change(year: Time.zone.today.year)
  end

  def set_canonical_register
    self.canonical_register = Register::Singer::REGISTER_TO_CANONICAL_REGISTER[register]
  end
end
