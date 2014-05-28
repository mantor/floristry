module ActiveRuote

  class Base # TODO should this be within Active::Participant ? First try failed.
    include ActiveAttr::Model
    include ActiveAttr::MassAssignment
    include ActiveModel::MassAssignmentSecurity
    extend Forwardable

    def initialize(participant)

      @participant = participant
      load_attributes(workitem)
    end

    def_delegators :@participant, :active?, :inactive?, :is_past?, :is_present?, :is_future?,
                   :id, :name, :params, :workitem, :era

    # Assign instance variables and @attributes hash then save and proceed (if required) if valid.
    #
    def update_attributes(new_attributes, options={})

      assign_attributes(new_attributes, options)
      load_attributes(new_attributes)

      save(options[:proceed]) if valid?
    end

    # Override default path # TODO really? look at the real to_partial_path maybe that's better
    #
    def to_partial_path

      k = self.class.to_s.parameterize.underscore
      "forms/tasks/#{k}/#{k}" # TODO is that really what we want? Segregated Components? Why?
    end

    # To make sure form_for use edit action instead of new
    #
    def persisted?() true end

    protected

    # Load attrs in @attributes hash if it's an attribute
    #
    # n.b. @attributes mimic ActiveRecord while attributes contains the list of ActiveAttr `virtual` attributes
    #
    def load_attributes(attrs)

      @attributes ||= {}
      attributes.each do |k, v|
        #attr[k] ||= nil  # TODO needed? e.g. if not already set in the ruote's workitem
        @attributes[k] = attrs[k]
      end
    end

    # Save workitem back in the workflow engine and proceed if needed
    #
    def save(proceed = false)

      wi = to_ruote_wi
      RuoteKit.storage_participant.do_update(wi)

      if proceed
        #wi['outcome'] = outcome             # TODO should be a state machine?
        wi['exited_at'] = Ruote.now_to_utc_s # TODO get rid of this dependency

        RuoteKit.storage_participant.proceed(wi)
      end

      true # TODO add validation or exception ?!
    end

    def to_ruote_wi

      wi = RuoteKit.storage_participant[id]
      attributes.each { |k, v| wi.set_field(k, v) }

      wi
    end

    #def from_ruote_wi
    #
    #  TODO is the big case switch supposed to be here???
    #end
  end
end