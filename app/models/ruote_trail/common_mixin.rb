module RuoteTrail

module CommonMixin

  CHILDREN = 2     # Branch expressions stores children expressions in the 3rd element
  ROOT_EXPID = '0' # Root expression id - yes, it's a string (e.g. 0_1_0)
  SEP = '!'        # FEID's field separator
  EXPID_SEP = '_'  # Expression id's child separator
  SUBID = 'empty_subid' # Replacement for the subid part of a FEID. We are not using the subid.
  FEID_REGEX = /\A.*!.*!.*\z/ # TODO add engine option

  def self.included(base)

    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
  end

  module InstanceMethods

    def to_wfid(id)

      id.split(SEP).last
    end

    def to_expid(id)

      id.split(SEP).first
    end

    # The FlowExpressionId (fei for short) is an process expression identifier.
    # Each expression when instantiated gets a unique fei.
    #
    # Feis are also used in workitems, where the fei is the fei of the
    # [participant] expression that emitted the workitem.
    #
    # Feis can thus indicate the position of a workitem in a process tree.
    #
    # Feis contain four pieces of information :
    #
    # * wfid : workflow instance id, the identifier for the process instance
    # * subid : a unique identifier for expressions (useful in loops)
    # * expid : the expression id, where in the process tree
    # * engine_id : only relevant in multi engine scenarii (defaults to 'engine')
    #
    class FlowExpressionId

      include RuoteTrail::CommonMixin

      attr_reader :id, :engineid, :wfid, :subid, :expid

      def initialize(id)

        if id.is_a? Hash

          @engineid = id['engine_id'] || 'engine'
          @expid = id['expid']
          @wfid = id['wfid']
          @id = to_id
        else

          @id = id
          s = id.split(SEP)
          @engineid = s[-4] || 'engine'
          @expid = s[-3]
          @wfid = s[-1]
        end
        @subid = SUBID
      end

      def to_id(opts = {})

        t_expid = (opts.include?(:expid)) ? opts[:expid] : expid

        [ t_expid, subid, wfid ].join(SEP)
      end

      # def self.to_storage_id(hfei)
      #
      #   if hfei.respond_to?(:to_storage_id)
      #     hfei.to_storage_id
      #   else
      #     "#{hfei['expid']}!#{hfei['subid'] || hfei['sub_wfid']}!#{hfei['wfid']}"
      #   end
      # end

      # Returns the last number in the expid. For instance, if the expid is
      # '0_5_7', the child_id will be '7'.
      #
      def child_id

        h.expid.split(EXPID_SEP).last.to_i
      end

      # Returns child_id... For an expid of '0_1_4', this will be 4.
      #
      def self.child_id(h)

        h['expid'].split(EXPID_SEP).last.to_i
      end

      # Returns true if other_fei is the fei of a child expression of
      # parent_fei.
      #
      def self.direct_child?(parent_fei, other_fei)

        %w[ wfid engine_id ].each do |k|
          return false if parent_fei[k] != other_fei[k]
        end

        pei = other_fei['expid'].split(EXPID_SEP)[0..-2].join(EXPID_SEP)

        (pei == parent_fei['expid'])
      end
    end
  end

  module ClassMethods

    def to_wfid(id)

      id.split(SEP).last
    end

    def to_expid(id)

      id.split(SEP).first
    end
  end

end
end