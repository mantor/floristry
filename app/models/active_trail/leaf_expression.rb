module ActiveTrail

  class LeafExpression < Expression

    include LeafExpressionMixin
  end
end

mixin = ActiveTrail.configuration.add_leaf_expression_behavior
ActiveTrail::LeafExpression.send(:include, mixin) if mixin