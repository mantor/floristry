module Floristry
  class Att < LeafProcedure
    def comparison

      "(#{raw_atts[0][1][0][1]} #{raw_atts[0][0]} #{raw_atts[0][1][1][1]})"
    end
  end
end