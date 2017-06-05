module ActiveTrail
  class Expression

    include ActiveTrail::CommonMixin
    include ExpressionMixin

    attr_reader :id, :name, :payload, :era

    def initialize(id, name, payload, vars, era)

      if id.is_a? FlowExpressionId

        @fei = id
        @id = @fei.to_feid
      else

        @fei = FlowExpressionId.new(id)
        @id = id
      end

      @name = name
      @payload = payload
      @era = era

      mixin = ActiveTrail.configuration.add_expression_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end