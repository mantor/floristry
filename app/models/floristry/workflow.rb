module Floristry
  # @FIXME DIRTY HACK: load it. If not, `Set` resolves to stdlib `Set`
  require "#{File.dirname(__FILE__) }/set"

  class Workflow < Floristry::BranchProcedure

    include Floristry::CommonMixin
    alias_method :id, :exid
    attr_reader :id, :launched_at, :terminated_at, :current_state, :version
    delegate vars: :@trail

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
        fei = FlowExecutionId.new(arg)
        trail = Trail.find_by_wfid(fei.exid) #TODO migration wfid -> exid
        raise ::ActiveRecord::RecordNotFound unless trail

        new(fei, trail)
      end
    end

    def self.terminate(exid)

      self.find(exid).trigger!(:terminate)
    end

    def self.error(exid)

      self.find(exid).trigger!(:error)
    end

    # A Workflow is a special type of Procedure. It has the responsibility to
    # build the Procedures tree from the Workflow Engine structure thus why its
    # initializer is different.
    #
    def initialize(id, trail)

      @trail = trail
      n, p, v, @version, @launched_at, @updated_at, @terminated_at, @current_state = parse_trail
      super(id, n, p, v, :past) # A Workflow is always in the past

      # @fei.expid = default_focus #unless @fei.focussed?
    end

    def updated_at

      if current_state == 'terminated'

        @terminated_at
      else

        if wi.respond_to? :updated_at

          wi.updated_at
        else

          @updated_at
        end
      end
    end

    # TODO - Do something cleaner || find a better name -------------------------------
    def collection()

      # todo change for is_branch?
      if @children.is_a?(Array)

        @children = branch(ROOT_NID, @trail.tree)
      end

      @children
    end

    def wi

      @wi ||= find_exp_by_expid(nid).instance
    end

    protected

    def self.find_by_scope(scope)

      @wfs = []
      Trail.send(scope).select(:id, :wfid).order(id: :desc).each do |t|
        @wfs << Workflow.find(t.wfid)
      end

      @wfs
    end

    def parse_trail

      name = @trail.name
      params = @trail.tree[3] # todo -> why not just store this directly in the trail, as we do for launched_at, etc ?
      vars = @trail.tree[4]
      version = @trail.version
      launched_at = @trail.launched_at
      updated_at = @trail.updated_at
      terminated_at = @trail.terminated_at
      current_state = @trail.current_state

      [ name, params, vars, version, launched_at, updated_at, terminated_at, current_state ]
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

    # Recursively search of something in the Procedure tree using a comparator block.
    # See first_part_pos() for an example.
    #
    def find_exp(exp, &comparator)

      i = 0
      s = ROOT_NID
      while i < exp.children.size

        s += NID_SEP
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

      exp = collection
      expid ||= current_pos[0]
      expids = expid.split(NID_SEP).map(&:to_i)

      i = 1 # Skip Workflow (Root) procedure i.e. 0
      while i < expids.size
        exp = exp.children[expids[i]]
        i += 1
      end

      exp
    end

    # Current `msg` position(s) - an array of `current` expid(s)
    #
    def current_pos

      unless @current_nids

        @current_nids = Array.new

        p = WorkflowEngine.process(@fei.exid)

        if p

          @root = p['data']['nodes']
          find_cnodes '0'
        end
      end

      @current_nids
    end

    def find_cnodes nid

      if @root[nid]['cnodes'].empty? && nid != '0'
         @current_nids << "#{exid}!#{@root[nid]['nid']}"
      else
        @root[nid]['cnodes'].each do |cnode|
          find_cnodes(cnode)
        end
      end
    end

    # Creates a Branch Procedure and its child Procedures.
    #
    # Recursively iterates through a Branch Procedure (e.g. sequence, concurrence)
    # and returns an object with its child Procedures (either Leaves or Branches).
    #
    # :expid is the relative position in the Workflow
    # :exp is used to navigate within the workflow internal structure
    #
    def branch(expid, parent_node)

      # feid = @fei.to_feid(expid: expid)

      obj = factory(id, find_era(expid), parent_node)

      parent_node[CHILDREN].each_with_index do |child_node, i|

        child_nid = "#{expid}#{NID_SEP}#{i}"
        if child_node.is_a? Array # todo -> why does payload ends up ad [3] in a sequence, adding `nil` at [2] ?
          branch_or_leaf = is_branch?(child_node[0].camelize) ? :branch : :leaf
          obj << self.send(branch_or_leaf, child_nid, child_node)
        end
      end

      obj
    end

    def leaf(expid, exp)

      # feid = @fei.to_feid(expid: expid)
      factory(expid, find_era(expid), exp)
    end

    # Returns proper Procedure type based on its name.
    #
    # Anything not an Procedure is considered a Participant Procedure, e.g.,
    # if == If, sequence == Sequence, admin == Participant, xyz == Participant
    #
    def factory(exid, era, exp)

      name, payload, params = extract(era, exp)
      klass_name = name.camelize

      if is_procedure? (klass_name)

        Floristry.const_get(klass_name).new(exid, name, params, payload, era)
      else

        fh = self.frontend_handler(name)
        params = ParametersInterpreter.new(params).to_hash

        unless params['model'].nil?
          name = params['model'].classify
        end

        fh[:class].new(exid, name, params, payload, era)
      end
    end

    # Participant frontend handler defining how the participant will be rendered
    #
    def frontend_handler(name)

      # TODO this should come from the DB, and the admin should have an interface
      frontend_handlers = [
          {
              :regex => Floristry::Ssh::Participant::PREFIX,
              :class => Floristry::Ssh::Participant,
              :options => {}
          },
          {
              regex: Floristry::Web::Participant::PREFIX,
              class: Floristry::Web::Participant,
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

    def is_procedure?(name)

      Floristry.const_get(name) <= Floristry::Procedure ? true : false

    rescue NameError
      false

    end


    def is_branch?(name)

      Floristry.const_get(name) <= Floristry::BranchProcedure ? true : false

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
          payload = exp[1][3] ||= exp[3]

        when :future
          params = exp[1] # Params are directly at [1]
          payload = {}
      end

      [ exp[0], payload, params ]
    end
  end
end

mixin = Floristry.configuration.add_workflow_behavior
Floristry::Workflow.send(:include, mixin) if mixin