# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Guessing names') do
  before do
    srand(42)
  end

  scenario 'making a wrong guess' do
    log_in_with_magic_link(users(:uwe))
    click_on 'Namen raten'
    expect(page).to have_content('Namen raten')
    fill_in 'Vorname oder Spitzname',	with: 'Foo'
    click_on 'Raten'
    expect(page).to have_content('Leider falsch geraten! Das war Marit.')
  end

  scenario 'making a correct guess' do
    log_in_with_magic_link(users(:uwe))
    click_on 'Namen raten'
    expect(page).to have_content('Namen raten')
    fill_in 'Vorname oder Spitzname',	with: 'Marit'
    click_on 'Raten'
    expect(page).to have_content('Richtig!')
  end
end
