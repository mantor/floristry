module ActiveTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    attr_accessor :payload
    attr_reader :param, :params
    
    delegate :param, :params, to: :@parameters

    def initialize(id, name, params, payload, era)

      super

      @payload = payload
      @parameters = ActiveTrail::ParametersInterpreter.new(params)
    end
  end
end

mixin = ActiveTrail.configuration.add_leaf_expression_behavior
ActiveTrail::LeafExpression.send(:include, mixin) if mixin