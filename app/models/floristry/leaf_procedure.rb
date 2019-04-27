module Floristry

  class LeafProcedure < Procedure

    include LeafProcedureMixin

    attr_accessor :payload
    attr_reader :param, :params
    
    delegate :param, :params, :raw_params, to: :@parameters

    def initialize(id, name, params, payload, era)

      super

      @payload = payload
      @parameters = Floristry::ParametersInterpreter.new(params)
    end
  end
end

mixin = Floristry.configuration.add_leaf_procedure_behavior
Floristry::LeafProcedure.send(:include, mixin) if mixin