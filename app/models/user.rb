# frozen_string_literal: true

class User < ApplicationRecord
  STATUS_ACTIVE = 'active'
  STATUS_PAUSED = 'paused'
  STATUS_INACTIVE = 'inactive'

  STATUSES = [STATUS_ACTIVE, STATUS_PAUSED, STATUS_INACTIVE].freeze

  REGISTER_SOPRANO_1 = 'soprano_1'
  REGISTER_SOPRANO_2 = 'soprano_2'
  REGISTER_ALTO_1 = 'alto_1'
  REGISTER_ALTO_2 = 'alto_2'
  REGISTER_TENOR_1 = 'tenor_1'
  REGISTER_TENOR_2 = 'tenor_2'
  REGISTER_BASS_1 = 'bass_1'
  REGISTER_BASS_2 = 'bass_2'

  REGISTERS = [
    REGISTER_SOPRANO_1,
    REGISTER_SOPRANO_2,
    REGISTER_ALTO_1,
    REGISTER_ALTO_2,
    REGISTER_TENOR_1,
    REGISTER_TENOR_2,
    REGISTER_BASS_1,
    REGISTER_BASS_2
  ].freeze

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

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :roles_must_be_valid
  validates :phone_number, format: { with: INTERNATIONAL_PHONE_NUMBER_REGEX }, allow_blank: true
  validates :status, inclusion: STATUSES
  validates :register, inclusion: REGISTERS, allow_blank: true

  has_many :attendances, dependent: :destroy

  passwordless_with :email

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

  private

  def roles_must_be_valid
    return if roles.all? { |r| Roles::ROLES.include? r } && roles.uniq == roles

    errors.add :roles, I18n.t('roles.validation.message')
  end
end
