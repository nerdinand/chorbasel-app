# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Completing a profile') do
  scenario do
    log_in_with_magic_link(users(:uwe))
    expect(page).to have_content(
      'Dein Benutzerprofil ist unvollständig. Bitte hilf uns indem du die fehlenden Informationen einträgst.'
    )

    click_on 'Benutzerprofil vervollständigen'
    expect(page).to have_content('Benutzer:in bearbeiten')

    fill_in 'Spitzname', with: 'uwu'
    fill_in 'Anrede', with: 'Herr'
    fill_in 'Strasse', with: 'Teststrasse 123'
    fill_in 'PLZ', with: '4567'
    fill_in 'Ort', with: 'Musterstadt'
    fill_in 'Telefonnummer (mobil)', with: '+41761234567'
    fill_in 'Geburtsdatum', with: '1970-01-01'
    select 'Bass 1', from: 'Stimme'
    click_on 'Benutzer:in aktualisieren'

    expect(page).to have_content('Benutzer:in erfolgreich geändert.')
  end
end
