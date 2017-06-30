Rails.application.routes.draw do
  
  resources :flows
  post '/flows/:id/launch', controller: 'flows', action: :launch
end
