# frozen_string_literal: true

require 'rails_helper'

require_relative '../features/log_in_helpers'

RSpec.describe SongListItemsController do
  let(:phips) { users(:phips) }
  let(:concert1) { song_lists(:concert1) }
  let(:haerlig) { song_list_items(:concert1_härlig_är_jorden) }
  let(:joyful) { songs(:joyful_joyful) }

  before do
    passwordless_sign_in(phips)
  end

  describe '#new' do
    it 'renders the new template successfully' do
      get "/song_lists/#{concert1.id}/song_list_items/new"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Listeneintrag erstellen')
    end
  end

  describe '#edit' do
    it 'renders the edit template successfully' do
      get "/song_lists/#{concert1.id}/song_list_items/#{haerlig.id}/edit"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Listeneintrag bearbeiten')
    end
  end

  describe '#create' do
    describe 'with correct parameters' do
      let(:params) do
        { song_list_item: { name: '', song_list_id: concert1.id, song_id: joyful.id, position: 2 } }
      end

      it 'creates a record and redirects successfully' do
        expect do
          post "/song_lists/#{concert1.id}/song_list_items", params: params
          expect(response).to redirect_to(song_list_path(concert1))
        end.to change(SongListItem, :count).by(1)
      end
    end

    describe 'with missing notes' do
      let(:params) do
        { song_list_item: { name: '', song_list_id: concert1.id, song_id: '', position: 2 } }
      end

      it 'renders an error' do
        expect do
          post "/song_lists/#{concert1.id}/song_list_items", params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('Notizen muss ausgefüllt werden')
        end.not_to change(SongList, :count)
      end
    end
  end

  describe '#update' do
    describe 'with correct parameters' do
      let(:params) do
        { song_list_item: { name: 'Another name', song_list_id: concert1.id, song_id: haerlig.id,
                            notes: 'Here be notes.' } }
      end

      it 'updates a record and redirects successfully' do
        put "/song_lists/#{concert1.id}/song_list_items/#{haerlig.id}", params: params
        expect(response).to redirect_to(song_list_path(concert1.id))
      end
    end

    describe 'with missing notes' do
      let(:params) do
        { song_list_item: { name: '', song_list_id: concert1.id, song_id: '', position: 2 } }
      end

      it 'updates a record and redirects successfully' do
        put "/song_lists/#{concert1.id}/song_list_items/#{haerlig.id}", params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Notizen muss ausgefüllt werden')
      end
    end
  end

  describe '#destroy' do
    it 'destroys an existing record' do
      delete "/song_lists/#{concert1.id}/song_list_items/#{haerlig.id}"
      expect(response).to redirect_to(song_list_path(concert1.id))
    end
  end
end
