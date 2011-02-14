Camfed::Application.routes.draw do
  
  devise_for :users

  resources :surveys do
    member do
      post 'import'
    end
    collection do
      post 'sync_with_epi_surveyor'
    end
    resources :import_histories
    resources :questions
    resources :mappings
    resources :object_mappings
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

  resource 'home'
  
  root :to => "surveys#index"
  
end
