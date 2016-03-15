module RuoteTrail::ActiveRecord

  # Emulates an Expression by implementing interface and using mixins instead of inheritance.
  #
  class Base < ::ActiveRecord::Base

    self.abstract_class = true

    include RuoteTrail::CommonMixin
    include RuoteTrail::ExpressionMixin
    include RuoteTrail::ParticipantExpressionMixin

    ATTRIBUTES_TO_EXCLUDE = %w(id __feid__ __workitem__ created_at updated_at )

    serialize :__workitem__, JSON

    after_initialize :include_configured_mixin
    after_find :init_fei, :init_fields_and_params
    after_create :init_fields_and_params

    attr_accessor :era # TODO really?
    attr_reader :fei, :fields, :params

    # ActiveRecords participants can be search by their Rails ID or Workflow id (feid)
    #
    # This is required since the information in hand from a Workflow perspective is always the
    # Workflow ID, not it's Rails representation.
    #
    def self.find id

      obj = (id.is_a? Integer) ? find_by_id(id) : find_by___feid__(id)
      obj || raise(ActiveRecord::RecordNotFound)   # TODO this doesn't work, why ?
    end

    # The workflow engine pass the workitem through this method
    #
    # Save the workitem as an special attribute to be merged at proceed. Bypassing validation is necessary
    # since some Participant's model may have attributes that aren't currently present/valid.
    #
    def self.create(wi)

      attrs = Hash.new
      attrs['__workitem__'] = wi
      attrs['__feid__'] = FlowExpressionId.new(wi['fei'].symbolize_keys).to_feid({ no_subid: true })
      attrs['current_state'] = StateMachine.initial_state

      # wi.keep_if { |k, v| self.column_names.include?(k) } # TODO Is that the proper logic?

      obj = new(attrs)
      obj.save({ validate: false })
      obj
    end

    delegate :trigger!, :available_events, to: :state_machine

    def participant_name # TODO Backend / Frontend name

      init_fields unless @fields
      @fields['participant_name']
    end
    alias_method :name, :participant_name # TODO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    def save(*)

      trigger!(:open) if self.respond_to?(:current_state) && current_state == StateMachine.initial_state
      super
    end

    def update_attributes(*)

      trigger!(:start) if current_state == 'open'
      super
    end

    def fei=(fei) # TODO ###############################################################################################

      @fei = fei
      write_attribute(:__feid__, @fei.to_feid)
    end

    def image() false end

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed #TODO should be atomic

      receiver = Receiver.new(RuoteTrail::WorkflowEngine.engine)
      receiver.proceed(merged_wi)

      # TODO this sucks ass!
      # The trail seems to be written each time ruote 'steps' (each 0.8s).
      # Food for thought - If nothing better: Could we emulate atomicity by simply increasing the expid?
      sleep(1)
    end

    protected

    def state_machine

      @state_machine ||= StateMachine.new(self)
    end

    def init_fields_and_params

      @fields = __workitem__['fields'].except('params')
      @params = __workitem__['fields']['params'] || {}
    end

    def init_fei

      @fei = FlowExpressionId.new(__feid__)
    end

    # Provide the original wi with fields merged with model's attributes
    #
    # The wi submitted by the workflow engine is kept untouched in the __workitem__ attribute.
    # We merge every attributes except a few within the workitem.
    def merged_wi

      wi = attributes['__workitem__']

      # new_attrs = attributes.keys - ATTRIBUTES_TO_EXCLUDE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      new_attrs = attributes.reject { |k, v| %w(id __workitem__ created_at updated_at).include? k }

      wi['fields'].merge!(new_attrs)
      wi
    end

    def include_configured_mixin

      mixin = RuoteTrail.configuration.add_active_record_base_behavior
      self.class.send(:include, mixin) if mixin
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
      transition from: :open,         to: :in_progress
    end

    event :proceed do
      transition from: :in_progress,  to: :closed
      transition from: :late,         to: :closed
      transition from: :closed,       to: :closed
    end

    event :proceed_with_issues do
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

      @object.current_state
    end

    after_transition do |object, transition|

      object.update_attribute(:current_state, transition.to_state)
    end
  end
end

# Must be done outside of initialize, since we are dealing with class methods.
mixin = RuoteTrail.configuration.add_active_record_base_behavior
RuoteTrail::ActiveRecord::Base.send(:extend, "#{mixin}::ClassMethods".constantize) if mixin