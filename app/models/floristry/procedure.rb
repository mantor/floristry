module Floristry
  class Procedure

    include Floristry::CommonMixin
    include ProcedureMixin

    attr_reader :id, :name, :payload, :era

    def initialize(id, name, payload, vars, era)

      if id.is_a? FlowExecutionId

        @fei = id
        @id = @fei.id
      else

        @fei = FlowExecutionId.new(id)
        @id = id
      end

      @name = name
      @payload = payload
      @era = era

      mixin = Floristry.configuration.add_procedure_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end