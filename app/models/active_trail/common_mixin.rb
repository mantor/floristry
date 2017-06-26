module ActiveTrail::CommonMixin

  CHILDREN = 1     # Where branch expressions stores children expressions
  ROOT_EXPID = '0' # Root expression id - yes, it's a string (e.g. 0_1_0)
  SEP = '!'        # FEID's field separator
  EXPID_SEP = '_'  # Expression id's child separator
  NO_SUBID = 'empty_subid' # Replacement for the subid part of a FEID.
  FEID_REGEX = /\A([_\d]+!)?(\w+!)?\d{8}-\d{4}-((?!-).)+-((?!-).)+\z/ # 0_0_0!523f41ebdbc878b5b2226898e49efc30!20150216-0011-gofumihi-moribeshi

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
    # * engine_id : only relevant in multi engine scenario (defaults to 'engine')
    #
    class FlowExpressionId

      # include ActiveTrail::CommonMixin
# @todo here!!!!!!!!!!!!
      attr_accessor :id, :engineid, :wfid, :subid, :expid

      def initialize(id)

        @focus = true
        @id = id
        # if id.is_a?(String) && id =~ FEID_REGEX
        #
        #   s = id.split(SEP)
        #   @engineid = s[-4] || 'engine'
        #   @expid = s[-3] || default_expid
        #   @subid = s[-2] || NO_SUBID
        #   @wfid = s[-1]
        #   @id = to_feid
        #
        # elsif id.is_a?(Hash) && id.has_key?(:wfid)
        #
        #   @engineid = id[:engine_id] || 'engine'
        #   @expid = id[:expid] || default_expid
        #   @subid = id[:subid] || NO_SUBID
        #   @wfid = id[:wfid]
        #   @id = to_feid
        # else
        #
        #   raise ActiveRecord::RecordNotFound
        # end
      end

      def focussed?() @focus end # Identifies whether a specific expid was requested

      def to_feid(opts = {})

        @id
        # expid = opts.include?(:expid) ? opts[:expid] : @expid
        # subid = opts.include?(:no_subid) ? NO_SUBID  : @subid
        #
        # [ expid, subid, @wfid ].join(SEP)
      end

      protected

      def default_expid

        @focus = false
        ROOT_EXPID
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