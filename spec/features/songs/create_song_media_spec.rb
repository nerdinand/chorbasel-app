# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Creating song media') do
  scenario do
    log_in_with_magic_link(users(:phips))
    click_on 'Lieder', visible: false
    expect(page).to have_content('Lieder')
    click_on 'Härlig är jorden'
    expect(page).to have_content('Härlig är jorden')
    click_on 'Neue Mediendatei'

    select 'Notenblatt', from: 'Art'
    attach_file 'Datei', Rails.root.join('spec/fixtures/files/Härlig_är_jorden.pdf')
    click_on 'Mediendatei erstellen'
    expect(page).to have_content('Mediendatei erfolgreich erstellt.')
  end
end
