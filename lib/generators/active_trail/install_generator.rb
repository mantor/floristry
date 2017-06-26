require 'rails/generators/base'

module ActiveTrail
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    require 'rails/generators/migration'
    include Rails::Generators::Migration
    require 'rake'

    def copy_migrations

      Rails.application.load_tasks
      Rake::Task['railties:install:migrations'].reenable
      Rake::Task['active_trail:install:migrations'].invoke
    end

    def migrate

      rake("db:migrate")
    end

    def copy_initializer_template

      copy_file 'initializer.rb', 'config/initializers/active_trail.rb'
    end

    def mount_engine_route

      # todo Add
      # put   '/hookhandler/:id/launched',  controller: 'active_trail/hookhandler', action: :launched, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # put   '/hookhandler/:id/returned',  controller: 'active_trail/hookhandler', action: :returned, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # put   '/hookhandler/:id/error',  controller: 'active_trail/hookhandler', action: :error, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # put   '/hookhandler/:id/terminated',  controller: 'active_trail/hookhandler', action: :terminated, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }

      # resources :workflows, controller: 'active_trail/workflows',  except: :update, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # patch   '/workflows/:id/edit',  controller: 'active_trail/workflows', action: :update, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # put     '/workflows/:id/',  controller: 'active_trail/workflows', action: :update, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }
      # put     '/workflows/:id/edit',  controller: 'active_trail/workflows', action: :update, as: :update_workflow, :constraints => { :id => /[0-9A-Za-z\-\.]+/ }


      route("mount ActiveTrail::Engine => '/trail'")
    end

    def install_flor_and_flack

      say("\n- Would you like me to install Flack and Flor inside: #{File.expand_path("..", Dir.pwd)}")
      r = ask("(If you are installing the dummy test app, type yes)", :limited_to => ["yes", "y", "no", "n"])

      if r.match(/y|yes/i)

        inside('../') do

          run('git clone https://github.com/floraison/flor && cd flor && git checkout v0.14.0')
          run('git clone https://github.com/floraison/flack')
        end

        say("Copying default Flack hooks and taskers inside ../flack/envs/dev/lib/")
        directory("flack/lib/hooks/", "../flack/envs/dev/lib/hooks")
        directory("flack/lib/taskers/", "../flack/envs/dev/lib/taskers")
      end
    end

    def self.next_migration_number path

      if @previous_stamp.nil?
        @previous_stamp = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      else
        @previous_stamp += 1
      end

      @previous_stamp.to_s
    end

  end
end