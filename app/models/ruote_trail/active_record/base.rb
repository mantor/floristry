module RuoteTrail::ActiveRecord

  class Base < ActiveRecord::Base

    self.abstract_class = true

    include RuoteTrail::CommonMixin
    include RuoteTrail::ExpressionMixin
    include RuoteTrail::LeafExpressionMixin

    ATTRIBUTES_TO_REMOVE = %w(id __feid__ __workitem__ created_at updated_at state)

    attr_accessor :era

    delegate :current_state, :trigger!, :available_events, to: :state_machine

    # Create obj from serialized workitem as an attribute and bypass validations,
    # since some Participant models may have required attributes that we won't
    # initialize with default, valid values, since it defeats the purpose.
    # Think of a Web Form.
    #
    def self.create(wi_h)

      wi_h['__workitem__'] = JSON.generate(wi_h)
      wi_h['__feid__'] = FlowExpressionId.new(wi_h['fei']).to_id
      wi_h['state'] = StateMachine.initial_state
      wi_h.keep_if { |key, value| self.column_names.include?(key) }

      object = new(wi_h)
      object.save({validate: false})
      object
    end

    # ActiveRecords participants can be search by their Rails ID or Workflow id (feid)
    #
    # This is required since the information in hand from a Workflow perspective is always the
    # Workflow ID, not it's Rails representation.
    #
    def self.find id

      obj = (id.is_a? Integer) ? self.where(id: id).first : self.where(__feid__: id).first

      raise ActiveRecord::RecordNotFound unless obj
      obj
    end

    def save(*)
      trigger!(:start) if state == StateMachine.initial_state && persisted?
      super
    end

    # TODO show proper participant image
    #
    def image() false end

    # TODO check if we could create a RuoteHelperMixin for this. Add expid, feid, etc
    #
    def wfid

      __feid__.split('!').third
    end

    # TODO check if we could create a RuoteHelperMixin for this.
    #
    def ruote_timestamp
      t = Time.now
      "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC"
    end

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed #TODO should be atomic

      wi = merged_wi

      receiver = RuoteTrail::ActiveRecord::Receiver.new(RuoteKit.engine)
      receiver.proceed(wi)

      self.trigger!(:proceed)

      sleep(1) # TODO this sucks, but the trail seems to be written each time ruote 'steps' (@each 0.8s)
    end

    def state_machine
      @state_machine ||= StateMachine.new(self)
    end

    private

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

      wi['fields'] = wi['fields'].merge!(new_attrs)
      wi['fields']['exited_at'] = ruote_timestamp

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