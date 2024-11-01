# frozen_string_literal: true

require 'rails_helper'
require_relative 'log_in_helpers'

RSpec.describe('Logging in and out') do
  fixtures :users

  scenario 'Logging in with the code' do
    log_in_with_code
    expect(page).to have_content('Willkommen, Ferdi!')
    expect(page).to have_content('Dashboard')
  end

  scenario 'Logging in with the magic link' do
    log_in_with_magic_link
    expect(page).to have_content('Dashboard')
  end
end
