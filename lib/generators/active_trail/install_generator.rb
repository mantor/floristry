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