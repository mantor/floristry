module Floristry
  class Att < LeafProcedure
    def comparison

      "(#{raw_params[0][1][0][1]} #{raw_params[0][0]} #{raw_params[0][1][1][1]})"
    end
  end
end