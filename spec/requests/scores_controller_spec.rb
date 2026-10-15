# frozen_string_literal: true

require 'rails_helper'

require_relative '../features/log_in_helpers'

RSpec.describe ScoresController do
  let(:phips) { users(:phips) }
  let(:song_with_score) { songs(:härlig_är_jorden) }
  let(:song_without_score) { songs(:joyful_joyful) }

  before do
    passwordless_sign_in(phips)
  end

  describe '#new' do
    it 'renders the new template successfully' do
      get "/songs/#{song_without_score.id}/score/new"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Partitur')
    end
  end

  describe '#edit' do
    it 'renders the edit template successfully' do
      get "/songs/#{song_with_score.id}/score/edit"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Partitur')
    end
  end

  describe '#create' do
    describe 'with correct parameters' do
      let(:params) { { song_list: { name: 'Foo', status: 'in_preparation' } } }

      it 'creates a record and redirects successfully' do
        expect do
          post "/songs/#{song_without_score.id}/score", params: params
          expect(response).to redirect_to(song_lists_path)
        end.to change(SongList, :count).by(1)
      end
    end

    describe 'with missing name' do
      let(:params) { { song_list: { name: '', status: 'in_preparation' } } }

      it 'renders an error' do
        expect do
          post "/songs/#{song_without_score.id}/score", params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('Name muss ausgefüllt werden')
        end.not_to change(SongList, :count)
      end
    end
  end

  describe '#update' do
    describe 'with correct parameters' do
      let(:params) { { song_list: { name: 'Foo', status: 'in_preparation' } } }

      it 'updates a record and redirects successfully' do
        put "/songs/#{song_with_score.id}/score", params: params
        expect(response).to redirect_to(song_lists_path)
      end
    end

    describe 'with missing name' do
      let(:params) { { song_list: { name: '', status: 'in_preparation' } } }

      it 'updates a record and redirects successfully' do
        put "/songs/#{song_with_score.id}/score", params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Name muss ausgefüllt werden')
      end
    end
  end
end
