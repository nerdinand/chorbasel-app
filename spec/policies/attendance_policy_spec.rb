# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancePolicy do
  fixtures :users, :attendances, :calendar_events
  subject { described_class.new(user, attendance) }

  let(:attendance) { attendances(:uwe_choir_practice) }

  context 'with a user with the app role' do
    let(:user) { users(:ferdi) }

    it { is_expected.to permit_all_actions }
  end

  context 'with a user with the absences role' do
    let(:user) { users(:fabienne) }

    it { is_expected.to permit_all_actions }
  end

  context 'with a user with no roles for their own attendance' do
    let(:user) { users(:uwe) }

    it { is_expected.to forbid_only_actions(:index) }
  end

  context "with a user with no roles for an attendance that isn't theirs" do
    let(:user) { users(:marit) }

    it { is_expected.to permit_only_actions(:show) }
  end
end
