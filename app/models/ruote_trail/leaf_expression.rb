module RuoteTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      super(id, name, params, workitem, era) # TODO *args?

      mod = RuoteTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mod) if mod
    end

    def leaf?() true end
    def branch?() false end
  end
end