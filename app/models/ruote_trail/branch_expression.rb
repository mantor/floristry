module RuoteTrail
  class BranchExpression < Expression
    include Enumerable

    attr_reader :children

    def initialize (id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)

      @children = Array.new

      mod = RuoteTrail.configuration.add_branch_expression_behavior
      self.class.send(:include, mod) if mod
    end

    delegate :<<, :[], :last, :size, :each, :each_with_index, to: :@children
  end
end