# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe 'Syncing the calendar' do
  scenario 'syncing the calendar' do
    log_in_with_magic_link(users(:ferdi))
    click_on 'Chorkalender importieren'
    expect(page).to have_content('Chorkalender erfolgreich importiert.')
  end
end
