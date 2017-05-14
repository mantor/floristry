module ActiveTrail
  class Stall < LeafExpression
    def initialize(id, name, params, fields, era)

      super(id, name, params, fields, era)
      @params = params.flatten.delete_if{|x| x == '_att'}
    end

    def to_s

      s = ''
      if @params[0] && @params[3] # @todo wtf ?
        s.concat("#{@params[0]}: #{@params[3]}")
      end

      s
    end
  end
end