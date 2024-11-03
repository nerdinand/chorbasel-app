# frozen_string_literal: true

require 'rails_helper'
require_relative 'log_in_helpers'

def create_future_event!
  CalendarEvent.create!(
    starts_at: 1.week.from_now,
    ends_at: 1.week.from_now + 2.hours,
    uid: 'random1',
    event_created_at: Time.zone.now,
    summary: 'my future event'
  )
end

def create_excuse!(calendar_event)
  Attendance.create!(
    calendar_event:,
    user: users(:uwe),
    remarks: "Uwe:\n> Ich muss dann meine Katze streicheln und kann leider nicht in die Probe kommen.",
    status: 'excuse_requested'
  )
end

RSpec.describe('Accepting an excuse') do
  fixtures :users

  scenario do
    event = create_future_event!
    create_excuse!(event)

    log_in_with_magic_link(users(:fabienne))
    click_on 'Anwesenheiten', visible: false
    expect(page).to have_content('Anwesenheiten')
    click_on 'Uwe my future event'
    expect(page).to have_content('Anwesenheit bearbeiten')
    select 'Entschuldigt', from: 'Status'
    click_on 'Anwesenheit aktualisieren'
    expect(page).to have_content('Anwesenheit erfolgreich geändert.')
  end
end
