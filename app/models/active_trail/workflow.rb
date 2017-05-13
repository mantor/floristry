module ActiveTrail
  # @FIXME DIRTY HACK: load it. If not, `Set` resolves to stdlib `Set`
  require "#{File.dirname(__FILE__) }/set"

  class Workflow < ActiveTrail::BranchExpression

    include ActiveTrail::CommonMixin
    alias_method :id, :wfid
    attr_reader :fei, :launched_at, :updated_at, :completed_at, :current_state, :version

    def self.all

      self.find(:all)
    end

    def self.active

      self.find(:active)
    end

    def self.find(arg)

      if arg.is_a? Symbol
        self.find_by_scope arg
      else
        fei = FlowExpressionId.new(arg)
        trail = Trail.find_by_wfid(arg)
        raise ActiveRecord::RecordNotFound unless trail

        new(fei, trail)
      end
    end

    def self.complete(exid)

      self.find(exid).trigger!(:complete)
    end

    def self.error(exid)

      self.find(exid).trigger!(:error)
    end

    # A Workflow is a special type of Expression. It has the responsibility to
    # build the Expressions tree from the Workflow Engine structure thus why its
    # initializer is different.
    #
    def initialize(id, trail)

      n, f, p, @version, @launched_at, @updated_at, @completed_at, @current_state = parse_trail(trail)  # TODO terminated_at ?
      super(id, n, p, f, :past) # A Workflow is always in the past

      @children = branch(ROOT_EXPID, trail.tree['0']['tree'])

      @fei.expid = default_focus unless @fei.focussed?
    end

    def updated_at

      # We might deal with a workflow that doesn't implement this method, i.e. a remote participant
      # In that case, we just return the last time this Workflow replied to the Engine.
      if wi.respond_to? :updated_at

        wi.updated_at
      else

        @updated_at
      end
    end

    # TODO - Do something cleaner || find a better name -------------------------------
    def collection() @children end

    def wi

      @wi ||= find_exp_by_expid(expid).instance
    end

    protected

    def self.find_by_scope(scope)

      @wfs = []
      Trail.send(scope).select(:id, :wfid).order(id: :desc).each do |t|
        @wfs << Workflow.find(t.wfid)
      end

      @wfs
    end

    def parse_trail(t)

      name = t.name
      p = t.tree['0']['vars']
      f = t.tree['0']['vars']
      version = t.version
      launched_at = t.launched_at
      updated_at = t.updated_at
      completed_at = t.completed_at
      current_state = t.current_state

      [ name, f, p, version, launched_at, updated_at, completed_at, current_state ]
    end

    def find_era(expid)

      if current_pos.empty? || expid < current_pos.first
        :past
      elsif current_pos.include? expid
        :present
      else
        :future
      end
    end

    # Default to first active exp but if there's none select the first participant
    #
    def default_focus

      current_pos.empty? ? first_part_pos : current_pos.first
    end

    def first_part_pos

      find_exp(@children) do |exp| exp.is_participant? end
    end

    # Recursively search of something in the Expression tree using a comparator block.
    # See first_part_pos() for an example.
    #
    def find_exp(exp, &comparator)

      i = 0
      s = ROOT_EXPID
      while i < exp.children.size

        s += EXPID_SEP
        if comparator.call(exp.children[i])

          s += i.to_s
          break
        elsif exp.children[i].is_branch?

          s += find_exp(exp.children[i], &comparator)
        end

        i += 1
      end
      s
    end

    def find_exp_by_expid(expid)

      exp = @children
      expid = expid.split(EXPID_SEP).map(&:to_i)

      i = 1 # Skip Workflow (Define) expression i.e. 0
      while i < expid.size
        exp = exp.children[expid[i]]
        i += 1
      end

      exp
    end

    # Current workitem position(s) - an array of `current` expid(s)
    #
    # TODO could/should this be done using the active_trail?
    #
    def current_pos

      unless @current_nids

        @current_nids = Array.new

        p = WorkflowEngine.process(@fei.id)

        if p

          @define = p['data']['nodes']
          find_cnodes '0'
        end
      end

      @current_nids
    end

    def find_cnodes nid

      if @define[nid]['cnodes'].empty?
        @current_nids << @define[nid]['nid']
      else
        @define[nid]['cnodes'].each do |cnode|
          find_cnodes(cnode)
        end
      end
    end

    # Creates a Branch Expression and its child Expressions.
    #
    # Recursively iterates through a Branch Expression (e.g. define, sequence, concurrence)
    # and returns an object with its child Expressions (either Leaves or Branches).
    #
    # :expid is the relative position in the Workflow
    # :exp is used to navigate within Ruote's workflow internal structure
    #
    def branch(expid, parent_node)

      # feid = @fei.to_feid(expid: expid)

      obj = factory(expid, find_era(expid), parent_node)

      parent_node[CHILDREN].each_with_index do |child_node, i|

        child_nid = "#{expid}#{EXPID_SEP}#{i}"
        branch_or_leaf = is_branch?(child_node[0].camelize) ? :branch : :leaf

        obj << self.send(branch_or_leaf, child_nid, child_node)
      end

      obj
    end

    def leaf(expid, exp)

      # feid = @fei.to_feid(expid: expid)
      factory(expid, find_era(expid), exp)
    end

    # Returns proper Expression type based on its name.
    #
    # Anything not a Ruote Expression is considered a Participant Expression, e.g.,
    # if == If, sequence == Sequence, admin == Participant, xyz == Participant
    #
    def factory(exid, era, exp)

      name, fields, params = extract(era, exp)
      name = 'define' if exid == '0'
      klass_name = name.camelize

      if is_expression? (klass_name)

        ActiveTrail.const_get(klass_name).new(exid, name, params, fields, era)
      else

        fh = self.frontend_handler(name)
        fh[:class].new(exid, name, params, fields, era)
      end
    end

    # Participant frontend handler defining how the participant will be rendered
    #
    def frontend_handler(name)

      # TODO this should come from the DB, and the admin should have an interface
      frontend_handlers = [
          {
              :regex => ActiveTrail::Ssh::Participant::PREFIX,
              :class => ActiveTrail::Ssh::Participant,
              :options => {}
          },
          {
              regex: ActiveTrail::Web::Participant::PREFIX,
              class: ActiveTrail::Web::Participant,
              options: {}
          },
          {
              regex: ActiveTrail::IssueHandler::Participant::PREFIX,
              class: ActiveTrail::IssueHandler::Participant,
              options: {}
          },
          {   # Default: This one should not be editable by the user
              regex: '.*',
              class: Participant,
              options: {}
          }
      ]

      frontend_handlers.select { |h| name =~ /#{h[:regex]}/i }.first
    end

    def is_expression?(name)

      ActiveTrail.const_get(name) <= ActiveTrail::Expression ? true : false

    rescue NameError
      false

    end


    def is_branch?(name)

      ActiveTrail.const_get(name) <= ActiveTrail::BranchExpression ? true : false

    rescue NameError
      false

    end

    def extract(era, exp)

      case era
        when :present, :past
          # exp[1]['fields'] ||= {}
          # exp[2]['params'] ||= {}
          # fields = exp[1]['fields'].except('params')
          params = exp[1]
          fields = {}

        when :future
          fields = {}
          params = exp[1] # Params are directly at [1]
      end

      [ exp[0], fields, params ]
    end
  end
end

mixin = ActiveTrail.configuration.add_workflow_behavior
ActiveTrail::Workflow.send(:include, mixin) if mixin