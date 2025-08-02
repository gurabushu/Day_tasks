Rails.application.routes.draw do
  root 'users#index'
  
  resources :users do
    collection do
      get :completed
      get :analysis  # 分析ページ
    end
  end
  
  # API エンドポイント
  namespace :api do
    resources :tasks, only: [] do
      collection do
        get :analysis_data
      end
    end
  end
  
  resources :tasks, only: [:create, :destroy] do
    member do
      patch :complete
      patch :incomplete
    end
  end
end
