module Floristry
  class AttributesInterpreter

    attr_reader :atts, :raw_atts

    def initialize(atts)

      @atts = []
      @raw_atts = atts
      interpret atts
    end

    def att key

      @atts[key]
    end

    def to_hash

      a = atts.reject { |p| p.empty? }
      keys = a.values_at(* a.each_index.select {|i| i.even? })
      values = a.values_at(* a.each_index.select {|i| i.odd? })

      keys.zip(values).to_h
    end

    private

    def interpret (a)

      a.each {|v|
        if v && v[1].is_a?(Array)
          if v[1].size > 0
            interpret v[1]
          else
            @atts << v[0]
          end
        else
          @atts << v[1].to_s unless v.nil?
        end
      }
    end
  end
end