# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#show'

  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  passwordless_for :users, controller: 'sessions'

  constraints Passwordless::Constraint.new(User) do
    get 'dashboard' => 'dashboard#show'

    resources :users
    resources :attendances, only: %i[index edit new create update]

    namespace :calendar_events do
      resource :syncs, only: :create
    end

    resources :calendar_events, only: [] do
      resources :attendances, only: :create, controller: 'calendar_events/attendances'
    end
  end
end
