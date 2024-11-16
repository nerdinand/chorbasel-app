# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Downloading song media') do
  scenario do
    log_in_with_magic_link(users(:uwe))
    click_on 'Lieder', visible: false
    expect(page).to have_content('Lieder')
    click_on 'Härlig är jorden'
    expect(page).to have_content('Härlig är jorden')
    click_on 'Herunterladen'
    expect(page.body.size).to eq(413_634)
  end
end
