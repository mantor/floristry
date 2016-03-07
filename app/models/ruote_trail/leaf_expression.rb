module RuoteTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    def initialize(id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)

      mixin = RuoteTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end