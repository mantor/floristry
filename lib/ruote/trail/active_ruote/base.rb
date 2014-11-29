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

    # @TODO explain this
    #
    def self.find id

      if id.is_a? Integer
        object = self.where(id: id).first
      else
        object = self.where(__feid__: id).first
      end

      raise ActiveRecord::RecordNotFound unless object
      object
    end

    def wfid

      __feid__.split('!').third
    end

    def layout

      'layouts/ruote_trail/leaf-expression'
    end

    def image

      false
    end

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

      # wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency

      receiver = RuoteTrail::ActiveRuote::Receiver.new(RuoteKit.engine)
      receiver.proceed(wi)
    end

    def merge_attributes_into_fields
      original_wi = JSON.parse(attributes['__workitem__']) # TODO error handling
      new_attributes = attributes.reject { |key, value| ['id', '__workitem__', 'created_at', 'updated_at'].include? key }
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

  # class Base # TODO should this be within Active::Participant ? First try failed.
  #   include ActiveAttr::Model
  #   include ActiveAttr::MassAssignment
  #   include ActiveModel::MassAssignmentSecurity
  #   extend Forwardable
  #
  #   def initialize(participant)
  #
  #     @participant = participant
  #     load_attributes(workitem)
  #   end
  #
  #   def_delegators :@participant, :active?, :inactive?, :is_past?, :is_present?, :is_future?,
  #                  :id, :name, :params, :workitem, :era
  #
  #   # Assign instance variables and @attributes hash then save and proceed (if required) if valid.
  #   #
  #   def update_attributes(new_attributes, options={})
  #
  #     assign_attributes(new_attributes, options)
  #     load_attributes(new_attributes)
  #
  #     save(options[:proceed]) if valid?
  #   end
  #
  #   # Override default path # TODO really? look at the real to_partial_path maybe that's better
  #   #
  #   def to_partial_path
  #
  #     k = self.class.to_s.parameterize.underscore
  #     "forms/tasks/#{k}/#{k}" # TODO is that really what we want? Segregated Components? Why?
  #   end
  #
  #   # To make sure form_for use edit action instead of new
  #   #
  #   def persisted?() true end
  #
  #   protected
  #
  #   # Load attrs in @attributes hash if it's an attribute
  #   #
  #   # n.b. @attributes mimic ActiveRecord while attributes contains the list of ActiveAttr `virtual` attributes
  #   #
  #   def load_attributes(attrs)
  #
  #     @attributes ||= {}
  #     attributes.each do |k, v|
  #       #attr[k] ||= nil  # TODO needed? e.g. if not already set in the ruote's workitem
  #       @attributes[k] = attrs[k]
  #       self.write_attribute(k, attrs[k])
  #     end
  #   end
  #
  #   # Save workitem back in the workflow engine and proceed if needed
  #   #
  #   def save(proceed = false)
  #
  #     wi = to_ruote_wi
  #     RuoteKit.storage_participant.do_update(wi)
  #
  #     if proceed
  #       #wi['outcome'] = outcome             # TODO should be a state machine?
  #       wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency
  #
  #       RuoteKit.storage_participant.proceed(wi)
  #     end
  #
  #     true # TODO add validation or exception ?!
  #   end
  #
  #   def to_ruote_wi
  #
  #     wi = RuoteKit.storage_participant[id]
  #     attributes.each { |k, v| wi.set_field(k, v) }
  #
  #     wi
  #   end
  #
  #   #def from_ruote_wi
  #   #
  #   #  TODO is the big case switch supposed to be here???
  #   #end
  # end

end