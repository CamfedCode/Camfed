Camfed::Application.routes.draw do
  
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
  end
  
  root :to => "surveys#index"
  
end
