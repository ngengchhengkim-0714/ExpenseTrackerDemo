# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # Root path
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Transactions
  resources :transactions do
    collection do
      get :summary
    end
  end

  # Categories
  resources :categories, except: [:show]

  # Reports
  resources :reports, only: [:index] do
    collection do
      get :monthly
      get :trends
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
