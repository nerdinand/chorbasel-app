# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'roles validation' do
    let(:roles_validation_error_message) do
      %(Rollen darf nur Elemente aus ["choir_direction", "choir_life", "choir_image", "choir_money", \
"choir_activities", "thank_you_gifts", "sponsorships", "media", "absences", "it", "app"] enthalten und keine Duplikate)
    end

    context 'when roles has duplicates' do
      let(:user) { described_class.new(roles: %w[app app]) }

      it do
        user.validate
        expect(user.errors.full_messages).to include(roles_validation_error_message)
      end
    end

    context 'when roles has invalid roles' do
      let(:user) { described_class.new(roles: %w[admin]) }

      it do
        user.validate
        expect(user.errors.full_messages).to include(roles_validation_error_message)
      end
    end

    context 'when roles is valid' do
      let(:user) { described_class.new(roles: %w[app absences media]) }

      it do
        user.validate
        expect(user.errors.full_messages).not_to include(roles_validation_error_message)
      end
    end
  end

  describe '#roles_wrapper' do
    it { expect(users(:ferdi).roles_wrapper).to be_a(Roles) }
  end

  describe '#full_name' do
    context 'when nick_name is present' do
      it { expect(users(:ferdi).full_name).to eq('Ferdinand "Ferdi" Niedermann') }
    end

    context 'when no nick_name is present' do
      it { expect(users(:fabienne).full_name).to eq('Fabienne H') }
    end
  end

  describe '#display_name' do
    context 'when nick_name is present' do
      it { expect(users(:ferdi).display_name).to eq('Ferdi') }
    end

    context 'when no nick_name is present' do
      it { expect(users(:fabienne).display_name).to eq('Fabienne') }
    end
  end

  describe '#profile_complete?' do
    context 'when user has incomplete profile' do
      it { expect(users(:ferdi).profile_complete?).to be false }
    end

    context 'when user has complete profile' do
      it { expect(users(:fabienne).profile_complete?).to be true }
    end
  end

  describe '#human_status' do
    it { expect(users(:ferdi).current_human_status).to eq('Aktiv') }
  end
end
