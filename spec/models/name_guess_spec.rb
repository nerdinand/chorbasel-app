# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NameGuess do
  describe '#correct?' do
    it 'returns true when the guess matches the first name' do
      guess = described_class.new(guessee: users(:phips), guess: 'Philippe')

      expect(guess).to be_correct
    end

    it 'returns true when the guess matches the nick name' do
      guess = described_class.new(guessee: users(:phips), guess: 'Phips')

      expect(guess).to be_correct
    end

    it 'returns false when the guess does not match the first or nick name' do
      guess = described_class.new(guessee: users(:phips), guess: 'Uwe')

      expect(guess).not_to be_correct
    end
  end
end
