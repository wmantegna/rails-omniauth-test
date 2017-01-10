Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  resource :user, only: [:none] do
    collection do
      get :edit_password
      patch :update_password
    end
  end

  root 'home#index'
end
