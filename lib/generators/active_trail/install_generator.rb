require 'rails/generators/base'

module ActiveTrail
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_template

      copy_file 'initializer.rb', 'config/initializers/active_trail.rb'
    end

    def mount_engine_route
      inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-'ROUTES'
  # These where added by the `rails g active_trail:install` command")
  put   '/hookhandler/:id/launched',  controller: 'active_trail/hookhandler', action: :launched, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }
  put   '/hookhandler/:id/returned',  controller: 'active_trail/hookhandler', action: :returned, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }
  put   '/hookhandler/:id/error',  controller: 'active_trail/hookhandler', action: :error, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }
  put   '/hookhandler/:id/terminated',  controller: 'active_trail/hookhandler', action: :terminated, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }
  resources :workflows, controller: 'active_trail/workflows',  except: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }
  patch   '/workflows/:id/edit',  controller: 'active_trail/workflows', action: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }
  put     '/workflows/:id/',  controller: 'active_trail/workflows', action: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }
  put     '/workflows/:id/edit',  controller: 'active_trail/workflows', action: :update, as: :update_workflow, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }
  # mount ActiveTrail::Engine => '/trail' # todo is this really needed? Should be an option

  post    '/webparticipant/create', controller: 'active_trail/webparticipant', action: :create
      ROUTES
      end
    end

    def run_migrate_generator

      generate "active_trail:migrate"
    end

    # todo This should be in a "install:test" or something alike
    def install_flor_and_flack

      say("\n- Would you like me to install Flack and Flor inside: #{File.expand_path("..", Dir.pwd)}")
      r = ask("(If you are installing the dummy test app, type yes)", :limited_to => ["yes", "y", "no", "n"])

      if r.match(/y|yes/i)

        inside('../') do

          run('git clone https://github.com/floraison/flor')
          inside('flor') do
            run('git checkout v0.14.0') # Aligns with flack runtime dependency
            run('bundle install')
          end
          run('git clone https://github.com/floraison/flack')
          inside('flack') do
            run('bundle install')
          end
        end

        say("Copying default Flack hooks and taskers inside ../flack/envs/dev/lib/")
        directory("flack/lib/hooks/", "../flack/envs/dev/lib/hooks")
        directory("flack/lib/taskers/", "../flack/envs/dev/lib/taskers")
      end
    end

  end
end