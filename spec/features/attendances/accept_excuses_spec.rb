# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Accepting an excuse') do
  before do
    calendar_event = CalendarEvent.create(
      starts_at: 7.days.from_now,
      ends_at: 7.days.from_now + 2.hours,
      uid: 'random1',
      event_created_at: Time.zone.now,
      summary: 'my upcoming event'
    )

    Attendance.create(
      calendar_event:,
      user: users(:uwe),
      remarks: "Ich werde leider keine Lust haben.\n> Gruss Uwe",
      status: 'excuse_requested'
    )
  end

  scenario do
    log_in_with_magic_link(users(:fabienne))

    click_on 'Anwesenheiten'

    expect(page).to have_text('Zu bestätigende Abwesenheiten')
    expect(page).to have_text('Uwe my upcoming event')
    expect(page).to have_css('tr', text: 'Uwe S') do |tr|
      expect(tr).to have_css('.attendance-status-icon-excused')
      expect(tr).to have_css('.attendance-status-icon-excuse-requested')
    end

    click_on 'Uwe my upcoming event'

    expect(page).to have_text('Anwesenheit bearbeiten')
    expect(page).to have_text('Benutzer:in: Uwe S')
    expect(page).to have_text('Termin: my upcoming event')
    expect(page).to have_text('Ich werde leider keine Lust haben. > Gruss Uwe')

    select 'Entschuldigt', from: 'Status'
    click_on 'Anwesenheit aktualisieren'

    expect(page).to have_text('Anwesenheit erfolgreich geändert.')
    expect(page).to have_no_text('Zu bestätigende Abwesenheiten')
    expect(page).to have_css('tr', text: 'Uwe S') do |tr|
      expect(tr).to have_css('.attendance-status-icon-excused')
      expect(tr).to have_css('.attendance-status-icon-excused')
    end
  end
end
