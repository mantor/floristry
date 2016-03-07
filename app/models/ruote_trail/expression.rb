module RuoteTrail
  class Expression

    include RuoteTrail::CommonMixin
    include ExpressionMixin

    attr_reader :id, :name, :params, :workitem, :era

    def initialize(id, name, params = {}, workitem = {}, era = :present)

      if id.is_a? FlowExpressionId

        @fei = id
        @id = @fei.to_feid    # TODO isn't @id forwarded to @fei?
      else

        @fei = FlowExpressionId.new(id)
        @id = id
      end

      @name = name
      @params = params
      @workitem = workitem # TODO fields??
      @era = era

      mixin = RuoteTrail.configuration.add_expression_behavior
      self.class.send(:include, mixin) if mixin
    end
  end
end