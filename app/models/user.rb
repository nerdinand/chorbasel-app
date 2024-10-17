# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :roles_must_be_valid

  passwordless_with :email

  def role
    Roles.new(roles)
  end

  def full_name
    nick_name_part = ("\"#{nick_name}\"" if nick_name.present?)

    [first_name, nick_name_part, last_name].compact.join(' ')
  end

  private

  def roles_must_be_valid
    return if roles.all? { |r| Roles::ROLES.include? r } && roles.uniq == roles

    errors.add :roles, I18n.t('roles.validation.message')
  end
end
