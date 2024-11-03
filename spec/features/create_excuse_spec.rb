# frozen_string_literal: true

require 'rails_helper'
require_relative 'log_in_helpers'

def create_future_event!
  CalendarEvent.create!(
    starts_at: 1.week.from_now,
    ends_at: 1.week.from_now + 2.hours,
    uid: 'random2',
    event_created_at: Time.zone.now,
    summary: 'my future event'
  )
end

RSpec.describe('Creating an excuse') do
  fixtures :users

  scenario do
    create_future_event!

    log_in_with_magic_link(users(:uwe))
    expect(page).to have_content('my future event')
    click_on 'Entschuldigung erfassen'
    expect(page).to have_content('Entschuldigung erfassen')
    fill_in 'Entschuldigung', with: 'Ich muss dann meine Katze streicheln und kann leider nicht in die Probe kommen.'
    click_on 'Entschuldigung speichern'
    expect(page).to have_content('Entschuldigung erfolgreich erfasst.')
  end
end
