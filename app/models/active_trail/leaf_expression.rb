module ActiveTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    def initialize(id, name, params, fields, era)

      super(id, name, params, fields, era)

      mixin = ActiveTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end