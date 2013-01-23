Camfed::Application.routes.draw do
  
  devise_for :users

  resources :surveys do
    collection do
      post 'sync_with_epi_surveyor'
      post 'import_selected'
      get 'search'
      delete 'destroy_selected'
    end
    
    member do
      get 'edit'
      put 'update'
      post 'update_mapping_status'
    end
    
    resources :import_histories do
      collection do
        delete 'destroy_selected'
      end
    end
    
    resources :questions
    resources :mappings do
      collection do
        get 'source'
        post 'clone'

        get 'multimap'
        post 'multiclone'
      end
    end
    resources :object_mappings do
      collection do
        get :modify
      end
    end
  end
  
  resources :import_histories do
    collection do
      delete 'destroy_selected'
    end
  end
  
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

  resources :dictionaries  do
    collection do
      post 'upload'
      get 'sample_download'
    end
  end

  root :to => "surveys#index"

end
