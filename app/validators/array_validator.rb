# frozen_string_literal: true

class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.all? { |r| options[:in].include? r } && value.uniq == value

    record.errors.add attribute, I18n.t('validations.array.error_message', in: options[:in])
  end
end
