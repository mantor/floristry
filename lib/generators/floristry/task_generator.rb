require 'rails/generators/base'
require 'rails/generators/active_record/model/model_generator'

module Floristry
  class TaskGenerator < ActiveRecord::Generators::ModelGenerator
  source_root File.expand_path("../templates", __FILE__)
  source_paths << File.expand_path(ActiveRecord::Generators::ModelGenerator.default_source_root)

  desc "Generates a WebTask"

  def create_model_file

    Rails::Generators::namespace = Floristry::Web
    template 'task.rb', File.join('app/models/floristry/web', regular_class_path, "#{file_name}.rb")
  end

  def create_migration_file

    return unless options[:migration] && options[:parent].nil?
    attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
    migration_template 'task_migration.rb', File.join("db/migrate/create_floristry_#{table_name}.rb")
  end

  def create_layout_file

    template '_task.html.erb', File.join('app/views/floristry/web', regular_class_path, "_#{file_name}.html.erb")
  end

  end
end