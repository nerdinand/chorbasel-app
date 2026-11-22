# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard' do
  def create_event(starts_at, summary)
    CalendarEvent.create!(starts_at:, ends_at: starts_at + 2.hours, uid: summary,
                          event_created_at: Time.zone.now, summary:)
  end

  before do
    create_event(10.days.from_now, 'Letzter Termin')
    create_event(5.days.ago, 'Vergangener Termin')
    users(:uwe).update!(birth_date: 3.days.from_now.to_date.change(year: 1990))
    users(:marit).update!(birth_date: 20.days.from_now.to_date.change(year: 1990))

    passwordless_sign_in(users(:fabienne))
  end

  it 'shows birthdays up to the last event in the timeline' do # rubocop:disable RSpec/MultipleExpectations
    get root_path

    expect(response).to be_successful
    expect(response.body).to include("Geburtstag</span>\n      · #{users(:uwe).full_name}")
    expect(response.body).to include('1 Geburtstag')
    expect(response.body).not_to include(users(:marit).full_name)
  end

  it 'shows past events in the "Früher" section' do # rubocop:disable RSpec/MultipleExpectations
    get root_path

    past_section = response.body[response.body.index('id="dashboard-past"')..]
    expect(past_section).to include('Früher')
    expect(past_section).to include('Vergangener Termin')
  end
end
