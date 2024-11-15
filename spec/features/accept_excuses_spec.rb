# frozen_string_literal: true

require 'rails_helper'
require_relative 'log_in_helpers'

RSpec.describe('Accepting an excuse') do
  fixtures :users

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
      remarks: "Uwe:\n> Ich werde leider keine Lust haben.\n> Gruss Uwe",
      status: 'excuse_requested'
    )
  end

  scenario do
    log_in_with_magic_link(users(:fabienne))

    # navbar link is not visible (probably hidden like on mobile)
    click_on 'Anwesenheiten', visible: false

    expect(page).to have_content('Zu bestätigende Abwesenheiten')
    expect(page).to have_content('Uwe my upcoming event')
    expect(page).to have_content('Uwe S ❌ ❗️')

    click_on 'Uwe my upcoming event'

    expect(page).to have_content('Anwesenheit bearbeiten')
    expect(page).to have_content('Benutzer:in: Uwe S')
    expect(page).to have_content('Termin: my upcoming event')
    expect(page).to have_content('Uwe: > Ich werde leider keine Lust haben. > Gruss Uwe')

    select 'Entschuldigt', from: 'Status'
    click_on 'Anwesenheit aktualisieren'

    expect(page).to have_content('Anwesenheit erfolgreich geändert.')
    expect(page).to have_no_content('Zu bestätigende Abwesenheiten')
    expect(page).to have_content('Uwe S ❌ ❌')
  end
end
