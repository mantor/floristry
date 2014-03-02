require 'forwardable'

module RuoteTrail
  class BranchExpression < Expression
    include Enumerable
    extend Forwardable

    attr_reader :children

    def initialize (id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)

      @children = Array.new

      mod = RuoteTrail.configuration.add_branch_expression_behavior
      self.class.send(:include, mod) if mod
    end

    def_delegators :@children, :<<, :[], :last, :size, :each, :each_with_index
  end
end