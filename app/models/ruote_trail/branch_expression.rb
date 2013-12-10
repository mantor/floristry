module RuoteTrail
  class BranchExpression < Expression
    attr_reader :children

    def initialize (id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)

      @children = Array.new

      mod = RuoteTrail.configuration.add_branch_expression_behavior
      self.class.send(:include, mod) if mod
    end

    def << (child) @children << child end

    def each (&block) @children.each(&block) end

    def [] (id) @children[id] end
  end
end