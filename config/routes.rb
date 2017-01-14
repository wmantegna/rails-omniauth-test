Rails.application.routes.draw do
  
  devise_for :users, :controllers => { 
    # custom controllers
    omniauth_callbacks: 'omniauth_callbacks',
    confirmations: 'users/confirmations'
  }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup


  resource :users, only: [:none] do
    get ':id/edit_password', to: 'users#edit_password', as: :edit_password
    patch ':id/update_password', to: 'users#update_password', as: :update_password

    get ':id/edit_email', to: 'users#edit_email', as: :edit_email
    patch ':id/update_email', to: 'users#update_email', as: :update_email
  end

  post 'users/:id/cancel_email_change', to: 'users#cancel_email_change', as: :cancel_user_email_change
  post 'users/:id/send_confirmation', to: 'users#send_confirmation', as: :send_user_confirmation

  

  root 'home#index'
end
