module Floristry
  class If < BranchProcedure

    def comparison

      atts = children[0].raw_atts[0]
      comparator = atts[0]
      left = comparison_value(atts[1][0][1])
      right = comparison_value(atts[1][1][1])

      "if (#{left} #{comparator} #{right})"
    end

    private

    def comparison_value(att)

      comp_val = att
      if comp_val.is_a? Array
        comp_val = "#{comp_val[0][1]}.#{comp_val[1][1]}"
      end
      comp_val
    end
  end
end