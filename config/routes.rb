DomainHunt::Application.routes.draw do
  resources :domains do
    collection { post :import }
  end


  root :to => 'domains#index'
end
