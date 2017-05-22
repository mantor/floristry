module ActiveTrail

  class LeafExpression < Expression

    include LeafExpressionMixin

    attr_accessor :params
    attr_accessor :payload

    def initialize(id, name, params, fields, era)

      super
      @params = []
      #todo find a better name. Its not params that we receive. Check Flor glossary.
      lookup_params(params)
      lookup_payload(params)
    end

    private

    def lookup_params p

      p.each {|v|
        if v[1].is_a?(Array)
          if v[1].size > 0
            lookup_params v[1]
          else
            @params << v[0]
          end
        else
          @params << v[1].to_s
        end
      }
    end

    def lookup_payload p

      if p[0].at(3).is_a? Hash
        @payload = p[0][3]
      end
    end
  end
end

mixin = ActiveTrail.configuration.add_leaf_expression_behavior
ActiveTrail::LeafExpression.send(:include, mixin) if mixin