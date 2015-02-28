module RuoteTrail::ActiveRecord

  class Base < ActiveRecord::Base

    self.abstract_class = true

    include RuoteTrail::CommonMixin
    include RuoteTrail::ExpressionMixin
    include RuoteTrail::LeafExpressionMixin

    ATTRIBUTES_TO_REMOVE = %w(id __feid__ __workitem__ created_at updated_at state)

    after_find :init_fei

    attr_accessor :era

    delegate :current_state, :trigger!, :available_events, to: :state_machine

    # The workflow engine pass the workitem through this method
    #
    # Save the workitem as an special attribute to be merged at proceed. Bypassing validation is necessary
    # since some Participant's model may have attributes that aren't currently present/valid.
    #
    def self.create(wi_h)

      wi_h['__workitem__'] = JSON.generate(wi_h)
      wi_h['__feid__'] = FlowExpressionId.new(wi_h['fei']).to_feid
      wi_h['state'] = StateMachine.initial_state
      wi_h.keep_if { |k, v| self.column_names.include?(k) }

      obj = new(wi_h)
      obj.save({validate: false})
      obj
    end

    # ActiveRecords participants can be search by their Rails ID or Workflow id (feid)
    #
    # This is required since the information in hand from a Workflow perspective is always the
    # Workflow ID, not it's Rails representation.
    #
    def self.find id

      obj = (id.is_a? Integer) ? self.where(id: id).first : self.where(__feid__: id).first
      obj || raise(ActiveRecord::RecordNotFound)
    end

    def save(*)

      trigger!(:start) if state == StateMachine.initial_state && persisted?
      super
    end

    def fei=(fei)

      @fei = fei
      write_attribute(:__feid__, @fei.to_feid)
    end

    # TODO show proper participant image
    #
    def image() false end

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed #TODO should be atomic

      receiver = RuoteTrail::ActiveRecord::Receiver.new(RuoteKit.engine)
      receiver.proceed(merged_wi)

      self.trigger!(:proceed)

      # TODO this sucks ass!
      # The trail seems to be written each time ruote 'steps' (each 0.8s).
      # Food for thought - If nothing better: Could we emulate atomicity by simply increasing the expid?
      sleep(1)
    end

    def state_machine
      @state_machine ||= StateMachine.new(self)
    end

    def issues
      @issues ||= Issue.where(:__feid__ => __feid__)
    end

    protected

    def init_fei

      @fei = FlowExpressionId.new(__feid__)
    end

    def timestamp

      t = Time.now
      "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC"
    end

    # Provide the original wi with fields merged with model's attributes
    #
    # The wi submitted by the workflow engine is kept untouched in the __workitem__ field.
    # We merge every attributes except a few back within the workitem.
    #
    def merged_wi

      wi = JSON.parse(attributes['__workitem__'])

      # TODO It doesn't make sense to keep the __feid__ attribute within the workitem once we get out of ActiveRecord.
      # The Expression is supposed to have all this info (expids).
      #
      # new_attrs = attributes.keys - ATTRIBUTES_TO_REMOVE
      new_attrs = attributes.reject { |k, v| %w(id __workitem__ created_at updated_at).include? k }

      wi['fields'].merge!(new_attrs)
      wi['fields']['exited_at'] = timestamp

      wi
    end
  end

  class StateMachine
    include Statesman::Machine

    state :unstarted, initial: true
    state :started
    state :proceeded

    event :start do
      transition from: :unstarted,  to: :started
    end

    event :proceed do
      transition from: :started,    to: :proceeded
    end

    def last_transition
      if @storage_adapter.last.nil? && @object.state
        return @transition_class.new(@object.state, 0)
      end
      @storage_adapter.last
    end

    after_transition do |object, transition|
      object.state = object.current_state
      object.save
    end
  end
end