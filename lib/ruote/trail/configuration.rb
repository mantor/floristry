module RuoteTrail

  class << self
    attr_accessor :configuration
  end

  def self.configure

    self.configuration ||= Configuration.new

    yield(configuration)
  end

  class Configuration

    attr_accessor :add_leaf_expression_behavior,
                  :add_branch_expression_behavior,
                  :add_expression_behavior

    def initialize

      @add_leaf_expression_behavior = nil    # TODO need to be here? could it be directly in the class, not initialize?
      @add_branch_expression_behavior = nil
      @add_expression_behavior = nil
    end
  end

end