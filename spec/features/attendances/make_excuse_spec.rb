# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Making an excuse') do
  before do
    CalendarEvent.create(
      starts_at: 7.days.from_now,
      ends_at: 7.days.from_now + 2.hours,
      uid: 'random1',
      event_created_at: Time.zone.now,
      summary: 'my upcoming event'
    )
  end

  scenario do
    log_in_with_magic_link(users(:uwe))
    expect(page).to have_text('my upcoming event')
    click_on 'Entschuldigung erfassen'
    expect(page).to have_text('Entschuldigung erfassen')
    fill_in 'Entschuldigung', with: "Ich werde leider keine Lust haben.\nGruss Uwe"
    click_on 'Entschuldigung speichern'
    expect(page).to have_text('Entschuldigung erfolgreich erfasst.')
    expect(page).to have_no_text('Entschuldigung erfassen')
  end
end
