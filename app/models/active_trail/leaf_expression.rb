module ActiveTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    attr_accessor :params
    attr_accessor :payload

    def initialize(id, name, params, payload, era)

      super
      @params = []
      @payload = payload
      #todo find a better name. Its not params that we receive. Check Flor glossary.
      lookup_params(params)
    end

    def params_to_h

      p = @params.reject { |p| p.empty? }
      keys = p.values_at(* p.each_index.select {|i| i.even? })
      values = p.values_at(* p.each_index.select {|i| i.odd? })

      keys.zip(values).to_h
    end

    private

    def lookup_params p

      p.each {|v|
        if v && v[1].is_a?(Array)
          if v[1].size > 0
            lookup_params v[1]
          else
            @params << v[0]
          end
        else
          @params << v[1].to_s unless v.nil?
        end
      }
    end
  end
end

mixin = ActiveTrail.configuration.add_leaf_expression_behavior
ActiveTrail::LeafExpression.send(:include, mixin) if mixin