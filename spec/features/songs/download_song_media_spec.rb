# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Downloading song media') do
  scenario do
    log_in_with_magic_link(users(:uwe))
    click_on 'Lieder'
    expect(page).to have_text('Liederlisten')
    click_on 'Alle Lieder'
    expect(page).to have_text('Lieder')
    click_on 'Härlig är jorden'
    expect(page).to have_text('Härlig är jorden')
    click_on 'Herunterladen'
    # TODO: fix this not finding the invisible link (debug running with JS?)
    find('a', text: 'Audioaufnahme (alle Stimmen)', visible: false).click
    expect(page.body.size).to eq(335_791)
  end
end
