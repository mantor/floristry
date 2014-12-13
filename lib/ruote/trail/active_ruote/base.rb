module RuoteTrail::ActiveRuote

  class Base < ActiveRecord::Base

    attr_accessor :era

    after_initialize :default_values

    self.abstract_class = true

    # attr_accessible :__workitem__ # TODO should be a mixin??!?!

    # Create obj but first inject serialized workitem as an attribute
    #
    def self.create(wi_h)

      wi_h['__workitem__'] = JSON.generate(wi_h)
      wi_h['__feid__'] = wi_h['fei'].dup.delete_if {| key, value | key == 'engine_id'}.values.reverse.join('!')

      super(wi_h.keep_if {| key, value | self.column_names.include?(key) })
    end

    # ActiveRecords participants can be search by their Rails ID or Workflow id (feid)
    #
    # This is required since the information in hand from a Workflow perspective is always the
    # Workflow ID, not it's Rails representation.
    #
    def self.find id

      if id.is_a? Integer
        obj = self.where(id: id).first
      else
        obj = self.where(__feid__: id).first
      end

      raise ActiveRecord::RecordNotFound unless obj
      obj
    end

    def wfid

      __feid__.split('!').third
    end

    def layout

      'layouts/ruote_trail/leaf-expression'
    end

    def image() false end

    def active?()     @era == :present end
    def inactive?()   @era != :present end
    # alias inactive? disabled?

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end


    # # Get an instance that will behave like a Participant Expression
    # #
    # def self.new_with_participant(p)
    #
    #   o = new() # or find? What's the diff between this ActiveRecord obj and the ActivePart obj?
    #
    #   @participant = p
    #   def_delegators :@participant, :active?, :inactive?, :is_past?, :is_present?, :is_future?,
    #                  :id, :name, :params, :workitem, :era
    # end

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed

      # TODO should update state machine

      # TODO remove __feid__ from new_attributes
      wi = merge_attributes_into_fields
      self.__workitem__ = JSON::generate(wi)
      self.save
      # wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency

      receiver = RuoteTrail::ActiveRuote::Receiver.new(RuoteKit.engine)
      receiver.proceed(wi)

      sleep(1) # TODO this sucks, but the trail seems to be written each time ruote 'steps' (@each 0.8s)
    end

    def merge_attributes_into_fields

      original_wi = JSON.parse(attributes['__workitem__']) # TODO error handling
      new_attributes = attributes.reject { |key, value| %w(id __workitem__ created_at updated_at).include? key } # TODO centralize list
      original_wi['fields'] = original_wi['fields'].merge!(new_attributes)

      original_wi
    end

    # def save
    #
    #   # TODO should update state machine
    #   super
    # end

    # # Override default path # TODO really? look at the real to_partial_path maybe that's better
    # #
    # def to_partial_path
    #
    #   k = self.class.to_s.parameterize.underscore
    #   "forms/tasks/#{k}/#{k}" # TODO is that really what we want? Segregated Components? Why?
    # end

    private

    def default_values
      @era = :future
    end
  end

  class Receiver < Ruote::Receiver

    # def initialize(engine) # TODO should be a Thread waiting for REST/MQ proceed request.
    #
    #   super(engine)
    #   Thread.new { listen }
    # end

    def proceed(workitem)
      reply(workitem)
    end
  end
end