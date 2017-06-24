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

      template 'initializer.rb', 'config/initializers/active_trail.rb'
    end

    def mount_engine_route

      route("mount ActiveTrail::Engine => '/trail'")
    end

    def install_flor_and_flack

      r = yes?("\n- Would you like me to install Flack and Flor inside: #{File.expand_path("..", Dir.pwd)}\n (If you are installing the dummy test app, type yes) [Y/n]")
      if r

        inside('../') do

          run('git clone https://github.com/floraison/flor && cd flor && git checkout v0.14.0')
          run('git clone https://github.com/floraison/flack')
        end

        say("Copying default Flack hooks and taskers inside ../flack/envs/dev/lib/")
        directory("flack/lib/hooks", "../flack/env/dev/lib/")
        directory("flack/lib/taskers", "../flack/env/dev/lib/")
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