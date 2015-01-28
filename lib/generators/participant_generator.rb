require 'rails/generators/base'
require 'rails/generators/active_record/model/model_generator'

class ParticipantGenerator < ActiveRecord::Generators::ModelGenerator
  source_root File.expand_path("../templates", __FILE__)
  source_paths << File.expand_path(ActiveRecord::Generators::ModelGenerator.default_source_root)

  desc "Generates an ActiveParticipant..."

  def create_model_file

    template 'participant.rb', File.join('app/models/participants', class_path, "#{file_name}.rb")
  end

  def create_migration_file

    return unless options[:migration] && options[:parent].nil?
    attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
    migration_template 'participant_migration.rb', File.join("db/migrate/create_#{table_name}.rb")
  end

  def create_layout_file

    template '_participant.html.erb', File.join('app/views/workflows', class_path, "_#{file_name}.html.erb")
  end

end