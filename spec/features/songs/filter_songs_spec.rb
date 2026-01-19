# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Filtering songs') do
  # Add expectations
  scenario do
    # Add code here
    log_in_with_magic_link(users(:uwe))
    click_on 'Lieder'
    expect(page).to have_content('Liederlisten')
    click_on 'Alle Lieder'
    expect(page).to have_content('Lieder')
    within('#language') do
      page.select 'Schwedisch'
    end

    click_on 'Filter anwenden'
    # Check that the page has some content
    expect(page).to have_content('Härlig är jorden')
  end
end
