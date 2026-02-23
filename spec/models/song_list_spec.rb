# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SongList do
  describe '#last_updated_at' do
    context 'when the song list has no songs' do
      subject(:song_list) do
        described_class.create(name: 'Test song list')
      end

      it "returns the song list's updated_at" do
        expect(song_list.last_updated_at).to eq(song_list.updated_at)
      end
    end

    context 'when a song list has items' do
      subject(:song_list) do
        described_class.create(name: 'Test song list',
                               song_list_items: [SongListItem.create(name: 'Test song list item 1')])
      end

      it 'changes the return value when a song list item is added' do
        expect do
          song_list.song_list_items << SongListItem.new(name: 'Test song list item')
        end.to change(song_list, :last_updated_at)
      end

      it 'changes the return value when a song list item is removed' do
        expect do
          song_list.song_list_items.first.destroy!
        end.to change(song_list.reload, :last_updated_at)
      end

      it 'changes the return value when a song list item gets updated' do
        song_list.song_list_items << SongListItem.new(name: 'Test song list item')

        expect do
          song_list.song_list_items[0].update(updated_at: 1.hour.from_now)
        end.to change(song_list, :last_updated_at)
      end
    end

    context 'when a song list has an item with a song' do
      subject(:song_list) { song_lists(:concert1) }

      it 'changes the return value when a song in the list gets updated' do
        expect do
          song_list.songs.first.update(updated_at: 1.hour.from_now)
        end.to change(song_list, :last_updated_at)
      end

      it 'changes the return value when a song in the list has a new song medium' do # rubocop:disable RSpec/ExampleLength
        song_medium = SongMedium.new(
          kind: 'choreography_video'
        )
        song_medium.file.attach(io: File.open('spec/fixtures/files/example.mp4', 'rb'), filename: 'example.mp4')

        expect do
          song_list.songs.first.song_media << song_medium
        end.to change(song_list, :last_updated_at)
      end

      it 'changes the return value when a song in the list has a song medium removed' do
        expect do
          song_list.songs.first.song_media.first.destroy!
        end.to change(song_list, :last_updated_at)
      end
    end
  end
end
