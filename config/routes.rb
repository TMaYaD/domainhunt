DomainHunt::Application.routes.draw do
  resources :domains


  root :to => 'domains#index'
end
