require 'rails/generators/base'

module Floristry
  class InstallGenerator < Rails::Generators::Base
    class_option :flack_and_flor, :type => :boolean, :default => false, :desc => "Install Flack and Flor"

    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_template

      copy_file 'initializer.rb', 'config/initializers/floristry.rb'
    end

    def mount_engine_route

      routes = [
        "# These where added by the `rails g floristry:install` command)\n",
        "put   '/hookhandler/:id/launched',  controller: 'floristry/hookhandler', action: :launched, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }",
        "put   '/hookhandler/:id/returned',  controller: 'floristry/hookhandler', action: :returned, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }",
        "put   '/hookhandler/:id/error',  controller: 'floristry/hookhandler', action: :error, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }",
        "put   '/hookhandler/:id/terminated',  controller: 'floristry/hookhandler', action: :terminated, :constraints => { :id => /[0-9A-Za-z\\-\\.]+/ }",
        "resources :workflows, controller: 'floristry/workflows',  except: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }",
        "patch   '/workflows/:id/edit',  controller: 'floristry/workflows', action: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }",
        "put     '/workflows/:id/',  controller: 'floristry/workflows', action: :update, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }",
        "put     '/workflows/:id/edit',  controller: 'floristry/workflows', action: :update, as: :update_workflow, :constraints => { :id => /([\\w\\.\\-]+)!?([0-9_]+)?+/ }",
        "post    '/webparticipant/create', controller: 'floristry/webparticipant', action: :create"
      ]

      routes.each do |r|
        unless File.readlines('config/routes.rb').grep(/monitor/).size > 0
          insert_into_file 'config/routes.rb', "\t#{r}\n", :before => /^end/
        end
      end
    end

    def run_migrate_generator

      generate "floristry:migrate"
    end

    def install_flack_and_flor

      if options[:flack_and_flor]
        say("\n- Installing Flack and Flor inside: #{File.expand_path("..", Dir.pwd)}")

        inside('../') do

          run('git clone https://github.com/floraison/flor')
          inside('flor') do
            run('git checkout v0.14.0') # Aligns with flack runtime dependency
            run('bundle install')
          end
          run('git clone https://github.com/floraison/flack')
          inside('flack') do
            run('bundle install')
            run('make migrate')
          end
        end

        say("Copying default Flack hooks and taskers inside ../flack/envs/dev/lib/")
        directory("flack/lib/hooks/", "../flack/envs/dev/lib/hooks")
        directory("flack/lib/taskers/", "../flack/envs/dev/lib/taskers")
      end
    end
  end
end