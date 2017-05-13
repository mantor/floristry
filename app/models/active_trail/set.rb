module ActiveTrail
  class Set < LeafExpression
    attr_accessor :field

    def initialize(id, name, params, fields, era)

      params = params.flatten.delete_if{|x| x == '_att'}

      # @todo wtf ?
      n = params[0].to_sym
      v = params[4]

      instance_variable_set(:@field, {'field_name' => "#{n}", 'value' => "#{v}"})
    end
  end
end