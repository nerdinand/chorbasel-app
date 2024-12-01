# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root 'dashboard#show'

  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  passwordless_for :users, controller: 'sessions'

  constraints Passwordless::Constraint.new(User) do
    get 'dashboard' => 'dashboard#show'

    resources :users, except: :destroy
    resources :attendances, only: %i[index edit new create update]

    namespace :calendar_events do
      resource :syncs, only: :create
    end

    resources :calendar_events, only: [] do
      resource :attendance, only: [] do
        resource :excuse, only: %i[new create], controller: 'calendar_events/attendances/excuses'
        resource :attendance, only: :create, controller: 'calendar_events/attendances/attendances'
      end
    end

    resources :songs do
      resources :song_media, only: %i[new create destroy]
    end

    resources :name_guesses, only: %i[new create]

    resources :feedbacks, only: %i[new create]

    resources :profiles, only: :index

    resources :statistics, only: :index

    resources :infos, except: %i[destroy show]
  end

  get '*path' => redirect('/users/sign_in'), via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/'
  }
end
