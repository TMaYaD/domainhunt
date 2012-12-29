DomainHunt::Application.routes.draw do
  resources :domains do
    collection {
      get :data_table
      post :hide
      post :like
    }
  end

  resources :comments, only: [:create]

  root :to => 'domains#index'
end
