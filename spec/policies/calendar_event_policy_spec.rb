# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarEventPolicy do
  fixtures :users
  subject { described_class.new(user, nil) }

  let(:user) { users(:ferdi) }

  it { is_expected.to permit_only_actions(:index, :show) }
end
