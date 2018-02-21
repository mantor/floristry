module ActiveTrail::ActiveRecord

  # This is the Backend listener Participant of Web participants - the only backend participant implemented by Rails
  # It is called by the transient REST Participant.
  # It emulates an Expression by implementing interface and using mixins instead of inheritance.
  #
  class Base < ::ActiveRecord::Base

    self.abstract_class = true

    include ActiveTrail::CommonMixin
    include ActiveTrail::ExpressionMixin
    include ActiveTrail::ParticipantExpressionMixin

    ATTRIBUTES_TO_EXCLUDE = %w(id __feid__ __msg__ )

    serialize :__msg__, JSON

    after_find :init_fei, :init_fields_and_params
    after_create :init_fei, :init_fields_and_params

    attr_reader :fei, :msg, :params

    delegate :trigger!, :available_events, :current_state, to: :state_machine

    # ActiveRecords participants can be search by their Rails ID or Workflow id (feid)
    #
    # This is required since the information in hand from a Workflow perspective is always the
    # Workflow ID, not it's Rails representation.
    #
    def self.find id

      obj = (id.is_a? Integer) ? find_by_id(id) : find_by___feid__(id)
      obj || raise(ActiveRecord::RecordNotFound)   # TODO this doesn't work, why ?
    end

    # The workflow engine pass a message through this method via the Web participant ...
    #
    # Save the msg as a special attribute to be merged at return. Bypassing validation is necessary
    # since some Participant's model may have attributes that aren't currently present/valid.
    #
    def self.create(msg)

      msg =  ActiveSupport::HashWithIndifferentAccess.new(msg)
      self.validate_msg(msg)

      attrs = Hash.new
      attrs['__msg__'] = msg
      attrs['__feid__'] = FlowExpressionId.new("#{msg['exid']}!#{msg['nid']}").feid
      attrs['current_state'] = StateMachine.initial_state

      # wi.keep_if { |k, v| self.column_names.include?(k) } # TODO Is that the proper logic?

      obj = new(attrs)
      obj.trigger!(:open) if obj.respond_to?(:current_state) && obj.current_state == StateMachine.initial_state
      obj.save({validate: false})
      obj
    end

    def name

      @name ||= ActiveSupport::Inflector.demodulize(self.class.name)
    end
    alias_method :frontend_participant_name, :name

    def save(*)

      super
    end

    def update_attributes(*)

      trigger!(:start) if current_state == 'open'
      super
    end

    def fei=(fei) # TODO is this really required? why? sounds fishy.

      @fei = fei
      write_attribute(:__feid__, @fei.to_feid)
    end

    def image() false end

    def target

      @params['target'] || AssetUser::DEFAULT_ROLE
    end

    # If returning, merge back attributes within saved msg and reply to Workflow Engine
    #
    def return #TODO should be atomic

      ActiveTrail::WorkflowEngine.return(@fei.exid, @fei.nid, merged_msg)
      trigger!(:return)

      # TODO this sucks ass!
      # Flor will probably not process it straight away.
      # Food for thought - If nothing better: Could we emulate atomicity by simply increasing the expid?
      sleep(1)
    end

    # Resolution of module is problematic in the isolated engine - used by strong_params in workflow's controller
    #
    def module_name() 'web' end

    protected

    def state_machine

      @state_machine ||= StateMachine.new(self)
    end

    def init_fields_and_params

      @fields = __msg__['payload']
      @params = __msg__['attd'] || {}
    end

    def init_fei

      @fei = FlowExpressionId.new(__feid__)
    end

    # Provide the original payload with fields merged with model's attributes
    #
    # The msg submitted by the workflow engine is kept untouched in the __msg__ attribute.
    # We merge every attributes except a few within the msg.
    def merged_msg

      wi = attributes['__msg__']

      new_attrs = attributes.reject { |k, v| %w(id __msg__ __feid__ current_state created_at updated_at).include? k }

      wi['payload'].merge!(new_attrs)
      wi
    end

    def self.validate_msg msg

      raise ArgumentError.new("'msg' can't be nil") if msg.empty?
      raise ArgumentError.new("'msg' does not contain an 'exid'") unless msg.key?('exid')
      raise ArgumentError.new("'msg' does not contain an 'nid'") unless msg.key?('nid')
      raise ArgumentError.new("'msg' is missing the payload") unless msg.key?('payload')
      raise ArgumentError.new("'msg' is missing 'attd'") unless msg.key?('attd')
    end

  end

  class StateMachine
    include Statesman::Machine
    include Statesman::Events

    state :upcoming, initial: true
    state :open
    state :in_progress
    state :late
    state :closed
    state :completed_with_issues

    event :open do
      transition from: :upcoming,     to: :open
      transition from: :open,         to: :open
    end

    event :start do
      transition from: :upcoming,     to: :in_progress
      transition from: :open,         to: :in_progress
      transition from: :in_progress,  to: :in_progress
    end

    event :return do
      transition from: :in_progress,  to: :closed
      transition from: :late,         to: :closed
      transition from: :closed,       to: :closed
    end

    event :return_with_issues do
      transition from: :in_progress,  to: :completed_with_issues
      transition from: :late,         to: :completed_with_issues
    end

    event :late do
      transition from: :late,          to: :late
      transition from: :open,          to: :late
      transition from: :in_progress,   to: :late
    end

    # This avoids the default behavior which is to check in the transition history,
    # in order to return the latest transition 'to_state'.
    def current_state(force_reload: false)

      @object.read_attribute(:current_state)
    end

    after_transition do |object, transition|

      object.update_attribute(:current_state, transition.to_state)
    end
  end
end

mixin = ActiveTrail.configuration.add_active_record_base_behavior
ActiveTrail::ActiveRecord::Base.send(:include, mixin) if mixin
