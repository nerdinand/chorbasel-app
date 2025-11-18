# frozen_string_literal: true

require 'rails_helper'
require_relative '../log_in_helpers'

RSpec.describe('Creating a song') do
  scenario do
    log_in_with_magic_link(users(:phips))
    click_on 'Lieder'
    expect(page).to have_content('Liederlisten')
    click_on 'Alle Lieder'
    expect(page).to have_content('Lieder')
    click_on 'Neues Lied'
    expect(page).to have_content('Neues Lied')

    fill_in 'Name', with: 'Auld Lang Syne'
    fill_in 'Komponist:in', with: 'Robert Burns'
    fill_in 'Arrangeur:in', with: 'Philippe A. Rayot'
    fill_in 'Tonart', with: 'Gb'
    fill_in 'Taktbezeichnung', with: '4/4'
    fill_in 'Sprache', with: 'Englisch'
    fill_in 'Liedtext', with: "Should auld acquaintance be forgot
And never brought to mind?
Should auld acquaintance be forgot
And days of auld lang syne?

For auld lang syne, my dear
For auld lang syne
We'll take a cup of kindness yet
For auld lang syne

We two have paddled in the stream
From morning sun till dine
But seas between us broad have roared
Since auld lang syne

For auld lang syne, my dear
For auld lang syne
We'll take a cup of kindness yet
For auld lang syne

And there's a hand my trusty friend,
That gives a hand of thine
We'll take a right good-will draught
For auld lang syne

For auld lang syne, my dear
For auld lang syne
We'll take a cup of kindness yet
For auld lang syne

For auld lang syne
"
    uncheck 'Im Repertoire'
    fill_in 'Genres', with: 'Volkslied'

    check 'Sopran'
    check 'Alt'
    check 'Tenor'
    check 'Bass'
    check 'Mezzosopran'

    click_on 'Lied erstellen'

    expect(page).to have_content('Lied erfolgreich erstellt.')
  end
end
