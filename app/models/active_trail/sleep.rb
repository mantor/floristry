module ActiveTrail
  class Sleep < LeafExpression
    attr_accessor :duration

    def initialize(id, name, params, fields, era)

      params = params.flatten.delete_if{|x| x == '_att'}
      instance_variable_set(:@duration, params[1])
    end
  end
end