module RuoteTrail
  class LeafExpression < Expression

    def initialize(id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era) # TODO *args?

      mod = RuoteTrail.configuration.add_leaf_expression_behavior
      self.class.send(:include, mod) if mod
    end

    def layout
      'layouts/ruote_trail/leaf-expression'
    end
  end
end