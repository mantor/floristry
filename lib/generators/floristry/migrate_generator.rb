module Floristry
  class MigrateGenerator < Rails::Generators::Base
    require 'rails/generators/migration'
    include Rails::Generators::Migration
    require 'rake'

    def copy_migrations

      Rails.application.load_tasks
      Rake::Task['railties:install:migrations'].reenable
      Rake::Task['floristry:install:migrations'].invoke
    end

    def migrate

      rake("db:migrate")
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