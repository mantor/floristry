module RuoteTrail::ActiveRuote

  class Base < ActiveRecord::Base

    attr_accessor :era
    self.abstract_class = true

    # attr_accessible :__workitem__ # TODO should be a mixin??!?!

    # Create obj but first inject serialized workitem as an attribute
    #
    def self.create(wi_h)

      wi_h['__workitem__'] = JSON.generate(wi_h)
      wi_h['__feid__'] = wi_h['fei'].dup.delete_if {| key, value | key == 'engine_id'}.values.reverse.join('!')
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

    def wfid

      __feid__.split('!').third
    end

    def layout

      'layouts/ruote_trail/leaf-expression'
    end

    def image() false end

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    alias_method :is_present?, :active?
    def inactive?()   @era != :present end
    alias_method :inactive?, :disabled?

    # If proceeding, merge back attributes within saved workitem and reply to Workflow Engine
    #
    def proceed

      # TODO should update state machine

      wi = merged_wi
      # wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency

      receiver = RuoteTrail::ActiveRuote::Receiver.new(RuoteKit.engine)
      receiver.proceed(wi)

      sleep(1) # TODO this sucks, but the trail seems to be written each time ruote 'steps' (@each 0.8s)
    end

    # Provide the original wi with fields merged with model's attributes
    #
    # The wi submitted by the workflow engine is kept untouched in the __workitem__ field.
    # We merge every attributes except a few back within the workitem.
    #
    def merged_wi

      wi = JSON.parse(attributes['__workitem__'])
      new_attrs = attributes.reject { |k, v| %w(id __feid__ __workitem__ created_at updated_at).include? k } # TODO centralize list
      wi['fields'] = wi['fields'].merge!(new_attrs)

      wi
    end

    # def save
    #
    #   # TODO should update state machine
    #   super
    # end

    # # Override default path to adjust namespace
    # #
    # # TODO to we really need this if we use a namespace? Aren't namespace directory directly followed?
    # #
    # def to_partial_path
    #
    #   k = self.class.to_s.parameterize.underscore
    #   "forms/tasks/#{k}/#{k}" # TODO is that really what we want? Segregated Components? Why?
    #                           # Yes but not necessarily at this place. We want workflows forms
    #                           # to act like standards rails stuff but creating an namespace would
    #                           # be important to make sure we can easily know what's part of Mantor
    #                           # and what's not and avoid conflicts. components/#{k}/#{k} ?
    # end
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