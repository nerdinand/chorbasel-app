# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Creating an attendance') do
  before do
    CalendarEvent.create(
      starts_at: 3.days.ago,
      ends_at: 1.hour.from_now,
      uid: 'random2',
      event_created_at: Time.zone.now,
      summary: 'my test event'
    )
  end

  scenario do
    log_in_with_magic_link(users(:uwe))
    expect(page).to have_content('my test event')
    click_on 'Anwesenheit eintragen'
    expect(page).to have_content('Anwesenheit erfolgreich eingetragen.')
  end
end
