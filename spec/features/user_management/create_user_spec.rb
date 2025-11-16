# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Creating an attendance') do
  include ActiveJob::TestHelper

  scenario do
    log_in_with_magic_link(users(:phips))

    # navbar link is not visible (probably hidden like on mobile)
    click_on 'Benutzer:innen', exact_text: 'Benutzer:innen'
    expect(page).to have_css('h1', exact_text: 'Benutzer:innen')
    click_on 'Neu'
    fill_in 'E-Mail', with: 'user@example.com'
    fill_in 'Vorname', with: 'New'
    fill_in 'Nachname', with: 'User'

    perform_enqueued_jobs do
      click_on 'Benutzer:in erstellen'
    end

    expect(page).to have_content('Benutzer:in erfolgreich erstellt und Einladungsemail verschickt!')

    email = ActionMailer::Base.deliveries.last
    expect(email.body.to_s).to eq(
      "Du wurdest zur ChorBasel-App eingeladen! Du kannst dich jetzt unter https://app.chorbasel.ch mit der \
E-Mail-Adresse einloggen, an die diese E-Mail versendet wurde. Die Bedienungsanleitung für die App findest du hier: https://github.com/nerdinand/chorbasel-app/blob/main/doc/bedienungsanleitung.md\n"
    )
    expect(email.from).to eq(['app@chorbasel.ch'])
    expect(email.to).to eq(['user@example.com'])
  end
end
