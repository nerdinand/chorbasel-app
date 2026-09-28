# frozen_string_literal: true

require 'rails_helper'

require_relative '../features/log_in_helpers'

RSpec.describe ProgramsController do
  let(:concert1) { song_lists(:concert1) }
  let(:christmas_concert) { song_lists(:christmas_concert) }
  let(:program1) { programs(:program1) }
  let(:christmas_concert_event) { calendar_events(:christmas_concert) }

  before do
    passwordless_sign_in(users(:phips))
  end

  describe '#create' do
    describe 'with correct parameters' do
      let(:params) do
        { program: { calendar_event_id: christmas_concert_event.id, song_list_id: christmas_concert.id } }
      end

      it 'creates a record and redirects successfully' do
        expect do
          post "/song_lists/#{christmas_concert.id}/programs", params: params
          expect(response).to redirect_to(edit_song_list_path(christmas_concert.id))
        end.to change(Program, :count).by(1)
      end
    end
  end

  describe '#destroy' do
    it 'destroys an existing record' do
      delete "/song_lists/#{concert1.id}/programs/#{program1.id}"
      expect(response).to redirect_to(edit_song_list_path(program1.song_list.id))
    end
  end
end
