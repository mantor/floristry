module Floristry
  class ParametersInterpreter

    attr_reader :params

    def initialize(params)

      @params = []
      interpret params
    end

    def param key

      @params[key]
    end

    def to_hash

      p = params.reject { |p| p.empty? }
      keys = p.values_at(* p.each_index.select {|i| i.even? })
      values = p.values_at(* p.each_index.select {|i| i.odd? })

      keys.zip(values).to_h
    end

    private

    def interpret (p)

      p.each {|v|
        if v && v[1].is_a?(Array)
          if v[1].size > 0
            interpret v[1]
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