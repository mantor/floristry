module Floristry::ActiveRecord

  # This is the Backend listener Participant of Web participants - the only backend participant implemented by Rails
  # It is called by the transient REST Participant.
  # It emulates an Expression by implementing interface and using mixins
  # instead of inheritance.
  #
  class Base < ::ActiveRecord::Base

    self.abstract_class = true

    include Floristry::CommonMixin
    include Floristry::ExpressionMixin
    include Floristry::ParticipantExpressionMixin

    ATTRIBUTES_TO_EXCLUDE = %w(id __feid__ __msg__ )

    serialize :__msg__, JSON

    after_find :init_fei, :init_fields_and_params # todo in Flor, fields is a key value pair in the payload
    after_create :init_fei, :init_fields_and_params # todo

    attr_reader :fei, :msg, :params

    delegate :trigger!, :available_events, :current_state, to: :state_machine

    # ActiveRecords participants can be search by their ActiveRecord id or
    # (Flor) Execution id (exid)
    #
    def self.find id

      obj = (id.is_a? Integer) ? find_by_id(id) : find_by___feid__(id)
      obj || raise(ActiveRecord::RecordNotFound)
    end

    # The workflow engine pass a message through this method via the Web tasker
    #
    # Save the msg as a special attribute to be merged at return.
    # Bypassing validation is necessary since at this point the data may be
    # inconsistent. Validations will run when data is fed to the model from
    # the frontend procedure
    #
    def self.create(msg)

      msg =  ActiveSupport::HashWithIndifferentAccess.new(msg)
      self.validate_msg(msg)

      attrs = Hash.new
      attrs['__msg__'] = msg
      attrs['__feid__'] = FlowExpressionId.new("#{msg['exid']}!#{msg['nid']}").id
      attrs['current_state'] = StateMachine.initial_state

      obj = new(attrs)
      obj.trigger!(:open) if obj.respond_to?(:current_state) && obj.current_state == StateMachine.initial_state
      obj.save({validate: false})
      obj
    end

    def name

      @name ||= ActiveSupport::Inflector.demodulize(self.class.name)
    end
    alias_method :frontend_procedure_name, :name

    def save(*)

      super
    end

    def update_attributes(*)

      trigger!(:start) if current_state == 'open'
      super
    end

    def fei=(fei)

      @fei = fei
      write_attribute(:__feid__, @fei.id)
    end

    # Merge back attributes within saved msg and reply to Workflow Engine
    #
    def return

      begin

        Floristry::WorkflowEngine.return(@fei.exid, @fei.nid, merged_msg)
        trigger!(:return)
      end

      # To keep in sync with Flor's tick
      sleep(0.3)
    end

    # Resolution of module is problematic in the isolated engine - used by
    # strong_params in workflow's controller
    #
    def module_name() 'web' end

    protected

    def state_machine

      @state_machine ||= StateMachine.new(self)
    end

    def init_fields_and_params

      @fields = __msg__['payload'] # todo fields are the key:values pairs in the payload
      @params = __msg__['attd'] || {}
    end

    def init_fei

      @fei = FlowExpressionId.new(__feid__)
    end

    # Merge Activerecord model attributes to the original workflow payload
    #
    # The msg submitted by the workflow engine is kept untouched in the __msg__
    # ActiveRecord attribute. Once completed, we merge each of Model's
    # attributes except a few within the msg.
    def merged_msg

      wi = attributes['__msg__']

      new_attrs = attributes.reject { |k, v|
        %w(id __msg__ __feid__ current_state created_at updated_at).include? k
      }

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
    state :terminated_with_issues

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
      transition from: :in_progress,  to: :terminated_with_issues
      transition from: :late,         to: :terminated_with_issues
    end

    event :late do
      transition from: :late,          to: :late
      transition from: :open,          to: :late
      transition from: :in_progress,   to: :late
    end

    # This avoids the default behavior which is to check in the transition
    # history, in order to return the latest transition 'to_state'.
    def current_state(force_reload: false)

      @object.read_attribute(:current_state)
    end

    after_transition do |object, transition|

      object.update_attribute(:current_state, transition.to_state)
    end
  end
end

mixin = Floristry.configuration.add_active_record_base_behavior
Floristry::ActiveRecord::Base.send(:include, mixin) if mixin
