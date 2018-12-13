module Floristry::CommonMixin

  CHILDREN = 1     # Where branch procedures stores children procedures
  ROOT_NID = '0'   # Root procedure id - yes, it's a string (e.g. 0_1_0)
  FEI_SEP = '!'    # FEI separator 
  NID_SEP = '_'    # NID separator
  FEI_REGEX = /\A([\w\.\-]+)!?([0-9_]+)?\z/ # domain0-u0-20170806.2124.pufatsonaju!0_1

  attr_reader :exid, :nid

  delegate :exid, :nid, to: :@fei

  def self.included(base)

    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
  end

  module InstanceMethods

    def to_nid(fei) fei.split(FEI_SEP).last end

    def to_exid(fei) fei.split(FEI_SEP).first end

    # The FlowExecutionId (fei for short) is an flow identifier.
    #
    # FEI contain two pieces of information :
    # * exid : execution instance id, the identifier for the flow instance
    # * nid : the node id - the position within the flow 
    #
    class FlowExecutionId

      attr_accessor :id, :exid, :nid

      def initialize(id)
        
        @focus = true
        @id = id
        if id.is_a?(String) && id.match(FEI_REGEX)

          s = id.split(FEI_SEP)

          if s.size > 1
            @exid = s[-2]
            @nid = s[-1]
          else
            @exid = s[-1]
          end
        else

          raise ActiveRecord::RecordNotFound # TODO not the right class of exception ( invalidrequest, parameter)
        end
      end

      def focussed?() @focus end # Identifies whether a specific nid was requested
      
    end
  end

  module ClassMethods

    def to_nid(fei)

      fei.split(FEI_SEP).last
    end

    def to_exid(fei)

      fei.split(FEI_SEP).first
    end
  end
end