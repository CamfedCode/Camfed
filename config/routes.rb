Camfed::Application.routes.draw do
  root :to => "surveys#index"
  
  resources :surveys do
    member do
      post 'import'
    end
    resources :import_histories
  end

  resources :import_histories
  
end
