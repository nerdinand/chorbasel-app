# frozen_string_literal: true

require 'rails_helper'

def create_ongoing_event!
  CalendarEvent.create!(
    starts_at: 3.days.ago,
    ends_at: 1.hour.from_now,
    uid: 'random',
    event_created_at: Time.zone.now,
    summary: 'my test event'
  )
end

RSpec.describe('Creating an attendance') do
  fixtures :users

  scenario do
    create_ongoing_event!

    log_in_with_magic_link(users(:uwe))
    expect(page).to have_content('my test event')
    click_on 'Anwesenheit eintragen'
    expect(page).to have_content('Anwesenheit erfolgreich eingetragen.')
  end
end
