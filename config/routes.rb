DomainHunt::Application.routes.draw do
  resources :domains do
    collection {
      post :import
      get :data_table
    }
  end


  root :to => 'domains#index'
end
