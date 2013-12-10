module RuoteTrail

  class << self
    attr_accessor :configuration
  end

  def self.configure

    self.configuration ||= Configuration.new

    yield(configuration)
  end

  class Configuration

    attr_accessor :add_leaf_expression_behavior,
                  :add_branch_expression_behavior,
                  :add_expression_behavior

    def initialize

      @add_leaf_expression_behavior = nil    # TODO need to be here? could it be directly inthe class, not initialize?
      @add_branch_expression_behavior = nil
      @add_expression_behavior = nil
    end
  end

  class Workflow

    @future = false

    def self.by_workitem(wi)

      @workitem = wi
      @fei = wi.fei
      self.get
    end

    def self.by_flow_expression_id(fei)

      @fei = fei # TODO validation: < Ruote::FlowExpressionId
      self.get
    end

    def self.by_storage_id(sid)

      @fei = Ruote::FlowExpressionId.from_id(sid)
      self.get
    end

    class << self
      alias_method :by_wi,  :by_workitem
      alias_method :by_fei, :by_flow_expression_id
      alias_method :by_sid, :by_storage_id
    end

    protected

    def self.workitem

      @workitem ||= RuoteKit.storage_participant[@fei] #TODO################################################## not ok, Factory????
      #@workitem ||= Workitem.find(@fei)
    end

    def self.get

      doc = RuoteKit.engine.storage.get('trail', @fei.wfid) # TODO should be somewhere else
      branch('0', doc['trail'])
    end

    # Iterates through a branch Expression (e.g. sequence, concurrence)
    #
    # Returns a branch Expression object with its child Expressions
    #
    def self.branch(expid, exp)

      era = get_era(expid)
      h = {                                         # TODO no :past, :present, :future here?????? diff then leaf??
              'participant_name' => exp[0],
              'fields' => { 'params' => exp[1] }
          }

      obj = RuoteTrail::ExpressionFactory.create(h, era)

      i = -1
      exp[2].each do |child|

        i += 1
        child_expid = "#{expid}_#{i}"

        branch_or_leaf = child[2].empty? ? :leaf : :branch
        obj << self.send(branch_or_leaf, child_expid, child)
      end

      obj
    end

    # Creates a Leaf Expression with its era
    #
    # Future Expressions only has params
    # Present Expressions is the expression currently holding the Ruote::Workitem
    # Past Expressions has fields (which includes params)
    #
    def self.leaf(expid, exp)

      era = get_era(expid)

      h = case era
        when :present
          self.workitem.to_h

        when :past
          {
            'participant_name' => exp[0],
            'fields' => exp[1]['fields'] # TODO should be load from non-trail to capture on-the-fly
                                         # process modifications? Only valid for present and future.
          }

        when :future
          {
            'participant_name' => exp[0],
            'fields' => { 'params' => exp[1] } # TODO should be load from non-trail to capture on-the-fly
                                               # process modifications? Only valid for present and future.
          }
        end

      RuoteTrail::ExpressionFactory.create(h, era)
    end

    # Until the current expid is used, we're in the past
    #
    # TODO this is only linear and doesn't take in count process concurrency
    #
    def self.get_era(expid)

      if @fei.expid == expid
        @future = true
        :present

      elsif @future
        :future

      else
        :past

      end
    end
  end
end