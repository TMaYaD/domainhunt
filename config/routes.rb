DomainHunt::Application.routes.draw do
  resources :domains do
    collection {
      get :data_table
      post :hide
      post :like
    }
  end

  resources :comments, only: :create
  put 'comments' => 'comments#create' # Hack for best in place

  root :to => 'domains#index'
end
