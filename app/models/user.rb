# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  def role
    Role.new(roles)
  end

  class Role
    ROLE_CHOIR_DIRECTION = 'Chor*Leitung'
    ROLE_CHOIR_LIFE = 'Chor*Leben'
    ROLE_CHOIR_IMAGE = 'Chor*Image'
    ROLE_CHOIR_MONEY = 'Chor*Chlütter'
    ROLE_CHOIR_ACTIVITIES = 'Chor*Aktivitäten'
    ROLE_THANK_YOU_GIFTS = 'Dankegeschenk-Koordination'
    ROLE_SPONSORSHIPS = 'GönnerInnen / Freunde'
    ROLE_MEDIA = 'Medienarbeit'
    ROLE_ABSENCES = 'Absenzenkoordination'
    ROLE_IT = 'IT, Design, Website'
    ROLE_APP = 'App'

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
      ROLE_APP
    ].freeze

    attr_reader :roles

    def initialize(roles)
      @roles = roles
    end

    def app?
      roles.include?(ROLE_APP)
    end
  end
end
