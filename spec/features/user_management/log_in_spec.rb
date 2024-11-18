# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Logging in and out') do
  scenario 'with the code' do
    log_in_with_code(users(:uwe))
    expect(page).to have_content('Willkommen, Uwe!')
    expect(page).to have_content('Dashboard')
    click_on 'Ausloggen', visible: false
    expect(page).to have_content('Erfolgreich ausgeloggt.')
  end

  scenario 'with the magic link' do
    log_in_with_magic_link(users(:uwe))
    expect(page).to have_content('Dashboard')
    click_on 'Ausloggen', visible: false
    expect(page).to have_content('Erfolgreich ausgeloggt.')
  end
end
