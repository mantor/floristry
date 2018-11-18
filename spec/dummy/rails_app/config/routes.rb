Rails.application.routes.draw do
  
  resources :flows
  post '/flows/:id/launch', controller: 'flows', action: :launch
	# These where added by the `rails g floristry:install` command)

	put   '/hookhandler/:id/launched',  controller: 'floristry/hookhandler', action: :launched, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
	put   '/hookhandler/:id/returned',  controller: 'floristry/hookhandler', action: :returned, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
	put   '/hookhandler/:id/error',  controller: 'floristry/hookhandler', action: :error, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
	put   '/hookhandler/:id/terminated',  controller: 'floristry/hookhandler', action: :terminated, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
	resources :workflows, controller: 'floristry/workflows',  except: :update, :constraints => { :id => /([\w\.\-]+)!?([0-9_]+)?+/ }
	patch   '/workflows/:id/edit',  controller: 'floristry/workflows', action: :update, :constraints => { :id => /([\w\.\-]+)!?([0-9_]+)?+/ }
	put     '/workflows/:id/',  controller: 'floristry/workflows', action: :update, :constraints => { :id => /([\w\.\-]+)!?([0-9_]+)?+/ }
	put     '/workflows/:id/edit',  controller: 'floristry/workflows', action: :update, as: :update_workflow, :constraints => { :id => /([\w\.\-]+)!?([0-9_]+)?+/ }
	post    '/webparticipant/create', controller: 'floristry/webparticipant', action: :create
end
