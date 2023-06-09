Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do 
    namespace :v1 do 
      namespace :items do 
        get 'find', to: 'find#show'
        get 'find_all', to: 'find#index'
      end
      namespace :merchants do 
        get 'find', to: 'find#show'
        get 'find_all', to: 'find#index'
      end
    end
  end

  namespace :api do 
    namespace :v1 do 
      resources :items do 
       get 'merchant', to: 'merchants#show'
      end
      resources :merchants, only: [:index, :show] do 
        resources :items, only: [:index]
      end
    end
  end 





end
