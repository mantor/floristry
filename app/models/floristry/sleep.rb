module Floristry
  class Sleep < LeafProcedure

    def duration

      params[0]
    end
  end
end