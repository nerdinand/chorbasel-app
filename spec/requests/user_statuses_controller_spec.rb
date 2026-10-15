# frozen_string_literal: true

require 'rails_helper'

require_relative '../features/log_in_helpers'

RSpec.describe UserStatusesController do
  let(:phips) { users(:phips) }
  let(:user) { users(:fabienne) }
  let(:user_status) { user_statuses(:fabienne) }

  before do
    passwordless_sign_in(phips)
  end

  describe '#new' do
    it 'renders the new template successfully' do
      get "/users/#{user.id}/user_statuses/new"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Neuer Benutzerstatus')
    end
  end

  describe '#edit' do
    it 'renders the edit template successfully' do
      get "/users/#{user.id}/user_statuses/#{user_status.id}/edit"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Benutzerstatus bearbeiten')
    end
  end

  describe '#create' do
    describe 'with correct parameters' do
      let(:params) do
        { user_status: { user_id: user.id, status: 'active', from_date: '2024-01-01', to_date: '2024-12-31' } }
      end

      it 'creates a record and redirects successfully' do
        expect do
          post "/users/#{user.id}/user_statuses", params: params
          expect(response).to redirect_to(edit_user_path(user))
        end.to change(UserStatus, :count).by(1)
      end
    end

    describe 'with incorrect date order' do
      let(:params) do
        { user_status: { user_id: user.id, status: 'active', from_date: '2024-12-31', to_date: '2024-01-01' } }
      end

      it 'creates a record and redirects successfully' do
        expect do
          post "/users/#{user.id}/user_statuses", params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('Enddatum muss größer als 2024-12-31 sein')
        end.not_to change(UserStatus, :count)
      end
    end
  end

  describe '#update' do
    describe 'with correct parameters' do
      let(:params) { { user_status: { status: 'paused' } } }

      it 'updates a record and redirects successfully' do
        put "/users/#{user.id}/user_statuses/#{user_status.id}", params: params
        expect(response).to redirect_to(edit_user_path(user))
      end
    end

    describe 'with missing status' do
      let(:params) { { user_status: { status: '' } } }

      it 'updates a record and redirects successfully' do
        put "/users/#{user.id}/user_statuses/#{user_status.id}", params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Status muss ausgefüllt werden')
      end
    end
  end

  describe '#destroy' do
    it 'destroys an existing record' do
      delete "/users/#{user.id}/user_statuses/#{user_status.id}"
      expect(response).to redirect_to(edit_user_path(user))
    end
  end
end
