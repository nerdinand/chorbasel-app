# frozen_string_literal: true

require 'rails_helper'

require_relative '../../features/log_in_helpers'

RSpec.describe Attendances::QuickActionsController do
  let(:fabienne) { users(:fabienne) }

  before do
    passwordless_sign_in(fabienne)
  end

  describe '#create' do
    let(:user) { users(:marit) }
    let(:calendar_event) { calendar_events(:choir_practice) }

    let(:params) do
      { attendance: { user_id: user.id, calendar_event_id: calendar_event.id, status: 'attended' } }
    end

    it 'creates a new attendance' do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
      expect do
        post :create, params: params, xhr: true
        expect(response).to be_successful
        expect(response.body).to match(
          %r{<turbo-stream action="remove" target="attendance-row-user-\d+"></turbo-stream><turbo-stream action="append" target="attendances-attended"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-attended"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-excuse_requested"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-excused"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-unknown"><template></template></turbo-stream>} # rubocop:disable Layout/LineLength
        )
      end.to change(Attendance, :count).by(1)
    end

    it 'renders error response when creating attendance fails' do # rubocop:disable RSpec/MultipleExpectations
      post :create, params: params.deep_merge({ attendance: { status: 'invalid' } }), xhr: true
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to match(
        %r{<turbo-stream action="append" target="attendance-row-user-\d+"><template></template></turbo-stream>}
      )
    end
  end

  describe '#update' do
    let(:calendar_event) { calendar_events(:choir_practice) }
    let(:attendance) do
      Attendance.create(
        calendar_event:,
        user: users(:marit),
        remarks: 'Ich möchte nicht.',
        status: 'excuse_requested'
      )
    end

    let(:params) do
      { attendance_id: attendance.id, attendance: { status: 'excused' } }
    end

    it 'updates an existing attendance' do # rubocop:disable RSpec/MultipleExpectations
      patch :update, params: params, xhr: true
      expect(response).to be_successful
      expect(response.body).to match(
        %r{<turbo-stream action="remove" target="attendance-row-user-\d+"></turbo-stream><turbo-stream action="append" target="attendances-excused"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-attended"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-excuse_requested"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-excused"><template></template></turbo-stream><turbo-stream action="replace" target="attendance-count-unknown"><template></template></turbo-stream>} # rubocop:disable Layout/LineLength
      )
    end

    it 'renders error response when updating attendance fails' do # rubocop:disable RSpec/MultipleExpectations
      patch :update, params: params.deep_merge({ attendance: { status: 'invalid' } }), xhr: true
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to match(
        %r{<turbo-stream action="append" target="attendance-row-user-\d+"><template></template></turbo-stream>}
      )
    end
  end
end
