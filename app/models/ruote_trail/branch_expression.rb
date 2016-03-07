require 'forwardable'

module RuoteTrail
  class BranchExpression < Expression
    include Enumerable
    extend Forwardable
    include BranchExpressionMixin

    attr_reader :children

    def initialize (id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)

      @children = Array.new

      mixin = RuoteTrail.configuration.add_branch_expression_behavior
      self.class.send(:include, mixin) if mixin
    end

    def_delegators :@children, :<<, :[], :first, :last, :size, :each, :each_with_index
  end
end