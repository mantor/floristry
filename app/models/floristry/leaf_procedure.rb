module Floristry

  class LeafProcedure < Procedure

    include LeafProcedureMixin

    attr_accessor :payload
    attr_reader :att, :atts
    
    delegate :att, :atts, :raw_atts, to: :@atts

    def initialize(id, name, atts, payload, era)

      super

      @payload = payload
      @atts = Floristry::AttributesInterpreter.new(atts)
    end
  end
end

mixin = Floristry.configuration.add_leaf_procedure_behavior
Floristry::LeafProcedure.send(:include, mixin) if mixin