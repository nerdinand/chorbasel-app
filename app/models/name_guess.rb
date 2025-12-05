# frozen_string_literal: true

class NameGuess < ApplicationRecord
  belongs_to :guesser, class_name: 'User'
  belongs_to :guessee, class_name: 'User'

  attr_accessor :guess

  def correct?
    [guessee.first_name, guessee.nick_name].compact_blank.map do |n|
      normalize(n)
    end.include? normalize(guess)
  end

  private

  def normalize(string)
    remove_diacritics(string).downcase
  end

  def remove_diacritics(string)
    string.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip
  end
end
