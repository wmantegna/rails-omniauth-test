Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  resource :users, only: [:none] do
    collection do
      get :edit_password
      patch :update_password
      get :edit_email
      patch :update_email
      post '/cancel_email_change_users', to: 'users#cancel_email_change', as: :cancel_email_change
      post '/resend_reconfirmation_email', to: 'users#resend_reconfirmation_email', as: :resend_reconfirmation_email
    end
  end
  root 'home#index'
end
