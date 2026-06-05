# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Filtering songs') do
  scenario do
    log_in_with_magic_link(users(:uwe))
    click_on 'Lieder'
    expect(page).to have_text('Liederlisten')
    click_on 'Alle Lieder'
    expect(page).to have_text('Joyful, joyful')
    expect(page).to have_text('Härlig är jorden')

    within('#language') do
      page.select 'Schwedisch'
    end

    click_on 'Filter anwenden'
    # Check that the page has some content
    expect(page).to have_no_text('Joyful, joyful')
    expect(page).to have_text('Härlig är jorden')

    within('#language') do
      page.select 'Englisch'
    end

    click_on 'Filter anwenden'
    # Check that the page has some content
    expect(page).to have_text('Joyful, joyful')
    expect(page).to have_no_text('Härlig är jorden')
  end
end
