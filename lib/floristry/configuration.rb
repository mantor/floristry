module Floristry

  class << self
    attr_accessor :configuration
  end

  def self.configure

    self.configuration ||= Configuration.new

    yield(configuration)
  end

  class Configuration

    attr_accessor :add_leaf_procedure_behavior,
                  :add_branch_procedure_behavior,
                  :add_procedure_behavior,
                  :add_workflow_behavior,
                  :add_active_record_base_behavior,
                  :add_trail_behavior,
                  :add_participant_behavior
  end
end