module RuoteTrail

  module LeafExpressionMixin

    def layout() 'layouts/ruote_trail/leaf-expression' end
  end

  class LeafExpression < Expression

    include LeafExpressionMixin

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      super(id, name, params, workitem, era) # TODO *args?

      mod = RuoteTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mod) if mod
    end
  end
end