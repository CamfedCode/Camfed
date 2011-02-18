Camfed::Application.routes.draw do
  
  devise_for :users

  resources :surveys do
    collection do
      post 'sync_with_epi_surveyor'
      post 'import_selected'
      get 'search'
      delete 'destroy_selected'
    end
    resources :import_histories
    resources :questions
    resources :mappings do
      collection do
        post 'clone'
        get 'source'
      end
    end
    resources :object_mappings do
      collection do
        get :modify
      end
    end
  end
  
  resources :import_histories
  
  resources :object_mappings do
    resources :field_mappings
  end
  resources :field_mappings
  
  namespace 'admin' do
    resource :configuration
    resources :users do
      member do
        put :activate
        put :inactivate
      end
    end
  end
  
  resources :salesforce_objects do
    collection do
      post :fetch_all
    end
    member do
      put :enable
      put :disable
    end
  end

  resource :home
  
  root :to => "surveys#index"
  
end
