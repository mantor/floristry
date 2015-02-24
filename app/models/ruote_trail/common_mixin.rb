module RuoteTrail
module CommonMixin

  CHILDREN = 2     # Branch expressions stores children expressions in the 3rd element
  ROOT_EXPID = '0' # Root expression id - yes, it's a string (e.g. 0_1_0)
  SEP = '!'        # FEID's field separator
  EXPID_SEP = '_'  # Expression id's child separator
  SUBID = 'empty_subid' # Replacement for the subid part of a FEID. We are not using the subid.
  FEID_REGEX = /\A.*!.*!\d{8}-\d{4}-((?!-).)+-((?!-).)+\z/ # 0_0_0!523f41ebdbc878b5b2226898e49efc30!20150216-0011-gofumihi-moribeshi
  WFID_REGEX = /\A\d{8}-\d{4}-((?!-).)+-((?!-).)+\z/ # 20150216-0011-gofumihi-moribeshi

  attr_reader :engineid, :wfid, :subid, :expid

  delegate :engineid, :wfid, :subid, :expid, to: :@fei

  def self.included(base)

    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
  end

  module InstanceMethods

    def to_wfid(feid) feid.split(SEP).last end

    def to_expid(feid) feid.split(SEP).first end

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

      attr_accessor :id, :engineid, :wfid, :subid, :expid

      def initialize(id)

        @subid = SUBID

        if id.is_a? Hash

          @engineid = id[:engine_id] || 'engine'
          @expid = id[:expid]
          @wfid = id[:wfid]
          @id = to_id

        else # String

          @id = id
          s = id.split(SEP)
          @engineid = s[-4] || 'engine'
          @expid = s[-3]
          @wfid = s[-1]
        end
      end

      def to_feid(opts = {})

        expid = (opts.include?(:expid)) ? opts[:expid] : @expid

        [ expid, @subid, @wfid ].join(SEP)
      end
    end
  end

  module ClassMethods

    def to_wfid(feid)

      feid.split(SEP).last
    end

    def to_expid(feid)

      feid.split(SEP).first
    end
  end
end
end