# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboard#show'

  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  passwordless_for :users, controller: 'sessions'

  constraints Passwordless::Constraint.new(User) do
    root 'dashboard#show', as: :dashboard
  end
end
