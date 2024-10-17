# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :roles_must_be_valid

  passwordless_with :email

  def role
    Roles.new(roles)
  end

  private

  def roles_must_be_valid
    return if roles.all? { |v| Roles::ROLES.include? v } && roles.uniq == values

    errors.add :roles, I18n.t('roles.validation.message')
  end
end
