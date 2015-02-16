module RuoteTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      super(id, name, params, workitem, era) # TODO *args?

      mixin = RuoteTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end