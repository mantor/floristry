Floristry::Engine.routes.draw do
  resources :workflows
  root 'workflows#index'
end