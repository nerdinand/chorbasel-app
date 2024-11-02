# frozen_string_literal: true

require 'rails_helper'
require_relative 'log_in_helpers'

RSpec.describe('Creating an attendance') do
  include ActiveJob::TestHelper
  fixtures :users

  scenario do
    log_in_with_magic_link(users(:phips))

    # navbar link is not visible (probably hidden like on mobile)
    click_on 'Benutzer', exact_text: 'Benutzer', visible: false
    expect(page).to have_css('h1', exact_text: 'Benutzer')
    click_on 'Neu'
    fill_in 'E-Mail', with: 'user@example.com'
    fill_in 'Vorname', with: 'New'
    fill_in 'Nachname', with: 'User'

    perform_enqueued_jobs do
      click_on 'Benutzer erstellen'
    end

    expect(page).to have_content('Benutzer erfolgreich erstellt.')

    email = ActionMailer::Base.deliveries.last
    expect(email.body.to_s).to eq(
      "Du wurdest zur Chorbasel-App eingeladen! Du kannst dich jetzt unter <a href=\"https://app.chorbasel.ch\">app.chorbasel.ch</a> mit der E-Mail-Adresse einloggen, an die diese E-Mail versendet wurde.\n"
    )
    expect(email.from).to eq(['app@chorbasel.ch'])
    expect(email.to).to eq(['user@example.com'])
  end
end
