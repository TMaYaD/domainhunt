DomainHunt::Application.routes.draw do
  resources :domains do
    collection {
      get :data_table
      post :hide
      post :like
    }
  end

  root :to => 'domains#index'
end
