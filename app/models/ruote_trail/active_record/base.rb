module RuoteTrail::ActiveRecord

  class Base < ActiveRecord::Base

    self.abstract_class = true

    include RuoteTrail::ExpressionMixin
    include RuoteTrail::LeafExpressionMixin

    attr_accessor :era

    delegate :current_state, :trigger!, :available_events, to: :state_machine

    # attr_accessible :__workitem__ # TODO should be a mixin??!?!

    # Create obj but first inject serialized workitem as an attribute
    #
    def self.create(wi_h)

      wi_h['__workitem__'] = JSON.generate(wi_h)
      wi_h['__feid__'] = wi_h['fei'].dup.delete_if { |key, value| key == 'engine_id'}.values.reverse.join('!')
      wi_h.keep_if { |key, value| self.column_names.include?(key) }

      super(wi_h)
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

    # TODO show proper participant image
    #
    def image() false end

    # TODO check if we could create a RuoteHelperMixin for this. Add expid, feid, etc
    #
    def wfid

      __feid__.split('!').third
    end

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed

      # TODO should update state machine

      wi = merged_wi
      # wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency

      receiver = RuoteTrail::ActiveRecord::Receiver.new(RuoteKit.engine)
      receiver.proceed(wi)

      sleep(1) # TODO this sucks, but the trail seems to be written each time ruote 'steps' (@each 0.8s)
    end

    def state_machine
      @state_machine ||= StateMachine.new(self)
    end

    def save
      require 'pp'

      pp "MY NEW STATE IS #{current_state} AND IVE BEEN SAVED!!!"
      # TODO should update state machine
      super
    end

    private

    # Provide the original wi with fields merged with model's attributes
    #
    # The wi submitted by the workflow engine is kept untouched in the __workitem__ field.
    # We merge every attributes except a few back within the workitem.
    #
    def merged_wi

      wi = JSON.parse(attributes['__workitem__'])
      new_attrs = attributes.reject { |k, v| %w(id __workitem__ created_at updated_at).include? k } # TODO centralize list
      wi['fields'] = wi['fields'].merge!(new_attrs)

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