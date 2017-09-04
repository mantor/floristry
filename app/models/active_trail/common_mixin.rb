module ActiveTrail::CommonMixin

  CHILDREN = 1     # Where branch expressions stores children expressions
  ROOT_EXPID = '0' # Root expression id - yes, it's a string (e.g. 0_1_0)
  SEP = '!'        # FEID's field separator
  NID_SEP = '_'    # Nid separator
  FEID_REGEX = /\A([\w\.\-]+)!?([0-9_]+)?\z/ # domain0-u0-20170806.2124.pufatsonaju!0_1

  attr_reader :engineid, :exid, :subid, :nid

  delegate :engineid, :exid, :nid, to: :@fei

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
      attr_accessor :id, :exid, :nid, :feid

      def initialize(id)

        # todo we should have exid -> Flor execution id -> For the whole flow : replaces wfid
        # todo                expid -> combination of exid and nid : replaces feid
        # todo                domain ?
        @focus = true
        @id = id
        if id.is_a?(String) && id.match(FEID_REGEX)

          s = id.split(SEP)

          if s.size > 1
            @feid = id
            @exid = s[-2]
            @nid = s[-1] || NO_SUBID
          else
            @exid = s[-1]
          end

          # @id = to_feid

        # elsif id.is_a?(Hash) && id.has_key?(:wfid)
        #
        #   @engineid = id[:engine_id] || 'engine'
        #   @expid = id[:expid] || default_expid
        #   @subid = id[:subid] || NO_SUBID
        #   @wfid = id[:wfid]
        #   @id = to_feid
        else

          raise ActiveRecord::RecordNotFound
        end
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