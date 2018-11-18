module Floristry

  class LeafExpression < Expression

    include LeafExpressionMixin

    attr_accessor :payload
    attr_reader :param, :params
    
    delegate :param, :params, to: :@parameters

    def initialize(id, name, params, payload, era)

      super

      @payload = payload
      @parameters = Floristry::ParametersInterpreter.new(params)
    end
  end
end

mixin = Floristry.configuration.add_leaf_expression_behavior
Floristry::LeafExpression.send(:include, mixin) if mixin