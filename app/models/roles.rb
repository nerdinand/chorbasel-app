# frozen_string_literal: true

class Role
  def initialize(role)
    @role = role
  end

  def human_name
    I18n.t("activerecord.attributes.role.enums.role.#{@role}")
  end

  def value
    @role
  end
end

class Roles
  ROLE_CHOIR_DIRECTION = 'choir_direction'
  ROLE_CHOIR_LIFE = 'choir_life'
  ROLE_CHOIR_IMAGE = 'choir_image'
  ROLE_CHOIR_MONEY = 'choir_money'
  ROLE_CHOIR_ACTIVITIES = 'choir_activities'
  ROLE_THANK_YOU_GIFTS = 'thank_you_gifts'
  ROLE_SPONSORSHIPS = 'sponsorships'
  ROLE_MEDIA = 'media'
  ROLE_ABSENCES = 'absences'
  ROLE_IT = 'it'
  ROLE_APP = 'app'
  ROLE_SONG_MANAGEMENT = 'song_management'

  ROLES = [
    ROLE_CHOIR_DIRECTION,
    ROLE_CHOIR_LIFE,
    ROLE_CHOIR_IMAGE,
    ROLE_CHOIR_MONEY,
    ROLE_CHOIR_ACTIVITIES,
    ROLE_THANK_YOU_GIFTS,
    ROLE_SPONSORSHIPS,
    ROLE_MEDIA,
    ROLE_ABSENCES,
    ROLE_IT,
    ROLE_APP,
    ROLE_SONG_MANAGEMENT
  ].freeze

  def initialize(roles)
    @roles = roles.map { |r| Role.new(r) }
  end

  def app?
    roles_values.include?(ROLE_APP)
  end

  def absences?
    roles_values.include?(ROLE_ABSENCES)
  end

  def choir_direction?
    roles_values.include?(ROLE_CHOIR_DIRECTION)
  end

  def choir_life?
    roles_values.include?(ROLE_CHOIR_LIFE)
  end

  def choir_money?
    roles_values.include?(ROLE_CHOIR_MONEY)
  end

  def song_management?
    roles_values.include?(ROLE_SONG_MANAGEMENT)
  end

  def self.all
    ROLES.map { |r| Role.new(r) }
  end

  attr_reader :roles

  private

  def roles_values
    roles.map(&:value)
  end
end
