Rails.application.routes.draw do

  # This is added by the `rails g active_trail:install` command
  mount ActiveTrail::Engine => '/trail'

  resources :flows
end
