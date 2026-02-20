# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongMedium do
  subject(:song_medium) { song_media(:härlig_är_jorden_recording_soprano) }

  it 'touches its song when it gets updated' do
    expect { song_medium.update!(register: 'mezzo-soprano') }.to(change { song_medium.song.reload.updated_at })
  end
end
