# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarSyncPolicy do
  fixtures :users
  subject { described_class.new(user, nil) }

  context 'with a user with the app role' do
    let(:user) { users(:ferdi) }

    it { is_expected.to permit_only_actions(:new, :create) }
  end

  context 'with a user with no roles' do
    let(:user) { users(:uwe) }

    it { is_expected.to forbid_all_actions }
  end
end
