# frozen_string_literal: true

require 'rails_helper'

require_relative '../features/log_in_helpers'

RSpec.describe SongListsController do
  let(:phips) { users(:phips) }
  let(:concert1) { song_lists(:concert1) }

  before do
    passwordless_sign_in(phips)
  end

  describe '#index' do
    it 'renders the index template successfully' do
      get '/song_lists'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Concert 1')
    end
  end

  describe '#show' do
    it 'renders the show template successfully' do
      get "/song_lists/#{concert1.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Concert 1')
      expect(response.body).to include('Härlig är jorden')
    end
  end

  describe '#new' do
    it 'renders the new template successfully' do
      get '/song_lists/new'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Neue Liederliste')
    end
  end

  describe '#edit' do
    it 'renders the edit template successfully' do
      get "/song_lists/#{concert1.id}/edit"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Liederliste bearbeiten')
    end
  end

  describe '#create' do
    describe 'with correct parameters' do
      let(:params) { { song_list: { name: 'Foo', status: 'in_preparation' } } }

      it 'creates a record and redirects successfully' do
        expect do
          post '/song_lists', params: params
          expect(response).to redirect_to(song_lists_path)
        end.to change(SongList, :count).by(1)
      end
    end

    describe 'with missing name' do
      let(:params) { { song_list: { name: '', status: 'in_preparation' } } }

      it 'creates a record and redirects successfully' do
        expect do
          post '/song_lists', params: params
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
        put "/song_lists/#{concert1.id}", params: params
        expect(response).to redirect_to(song_lists_path)
      end
    end

    describe 'with missing name' do
      let(:params) { { song_list: { name: '', status: 'in_preparation' } } }

      it 'updates a record and redirects successfully' do
        put "/song_lists/#{concert1.id}", params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Name muss ausgefüllt werden')
      end
    end
  end

  describe '#destroy' do
    it 'destroys an existing record' do
      delete "/song_lists/#{concert1.id}"
      expect(response).to redirect_to(song_lists_path)
    end
  end
end
