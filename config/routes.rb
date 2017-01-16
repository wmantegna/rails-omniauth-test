Rails.application.routes.draw do
  
  # Devise
  ######################################
  devise_for :users, :controllers => { 
    # custom controllers
    omniauth_callbacks: 'omniauth_callbacks',
    confirmations: 'users/confirmations'
  }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  ######################################


  # Non-Devise Authentication Features
  ######################################
  resources :identities, only: [:destroy]
  resources :users, only: [:none] do
    get :edit_password
    patch :update_password

    get :edit_email
    patch :update_email

    post :cancel_email_change
    post :send_confirmation
  end
  ######################################


  root 'home#index'
end
