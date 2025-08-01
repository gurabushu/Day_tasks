Rails.application.routes.draw do
  root 'users#index'
  resources :users, only: [:index] do
    collection do
      get :completed
    end
  end
  resources :tasks, only: [:create, :destroy] do
    member do
      patch :complete
      patch :incomplete
    end
  end
end
