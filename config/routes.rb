# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root 'dashboard#show'

  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  passwordless_for :users, controller: 'sessions'

  constraints Passwordless::Constraint.new(User) do # rubocop:disable Metrics/BlockLength
    get 'dashboard' => 'dashboard#show'

    resources :users, except: :destroy do
      resources :user_statuses, except: %i[index show]
    end

    resources :attendances, only: %i[index edit new create update] do
      patch :quick_update
    end

    resource :attendance do
      post :quick_create
    end

    namespace :calendar_events do
      resource :syncs, only: :create
    end

    resources :calendar_events, only: [:show] do
      resource :attendance, only: [] do
        resources :excuses, only: %i[new create], controller: 'calendar_events/attendances/excuses' do
          post :accept
        end
        resource :attendance, only: :create, controller: 'calendar_events/attendances/attendances'
      end
    end

    resources :song_lists do
      resources :song_list_items
      resources :song_media_bundle_downloads, only: %i[create show]

      resources :programs, only: %i[create destroy]
    end

    resources :songs do
      resources :song_media, only: %i[new create destroy]
    end

    resources :name_guesses, only: %i[new create]

    resources :feedbacks, only: %i[new create]

    resources :profiles, only: :index

    resources :statistics, only: :index

    resources :infos, except: %i[destroy show]

    resource :search, only: :show
  end

  get '*path' => redirect('/users/sign_in'), via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/'
  }
end
