module RuoteTrail
  module ExpressionMixin

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    def inactive?()   @era != :present end
    alias_method :disabled?, :inactive?
    alias_method :active?, :is_present?

    def layout() false end

    def to_partial_path
    #
      self.class.name.underscore
    #
    #   k = self.class.to_s.parameterize.underscore
    #   "forms/tasks/#{k}/#{k}" # TODO is that really what we want? Segregated Components? Why?
    #                           # Yes but not necessarily at this place. We want workflows forms
    #                           # to act like standards rails stuff but creating an namespace would
    #                           # be important to make sure we can easily know what's part of Mantor
    #                           # and what's not and avoid conflicts. components/#{k}/#{k} ?
    end
  end

  class Expression

    include ExpressionMixin
    include RuoteTrail::CommonMixin

    attr_reader :id, :name, :params, :workitem, :era

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      @id = id
      @fei = FlowExpressionId.new(id)
      @name = name
      @params = params
      @workitem = workitem
      @era = era

      mixin = RuoteTrail.configuration.add_expression_behavior
      self.class.send(:include, mixin) if mixin
    end

    def is_participant?() false end

    # Returns proper Expression type based on its name.
    #
    # Anything not a Ruote Expression is considered a Participant Expression, e.g.,
    # if == If, sequence == Sequence, admin == Participant, xyz == Participant
    #
    def self.factory(feid, era, exp)

      name, workitem, params = extract(era, exp)
      klass_name = name.camelize

      if is_expression? (klass_name)

        RuoteTrail.const_get(klass_name).new(feid, name, params, workitem, era) # TODO pass options via *args - if it's a good idea?!
      else

        fh = self.frontend_handler(name)
        obj = fh[:class].new(feid, name, params, workitem, era) # TODO pass options via *args - if it's a good idea?!
        #TODO Danny - Last commit removed the above line. We need this behaviour. Maybe somewhere else??
        ( fh[:class] == RuoteTrail::ActiveRecord::Participant ) ? obj.instance : obj
      end
    end

    protected

    # Participant frontend handler defining how the participant will be rendered
    #
    def self.frontend_handler(name)

      # TODO this should come from the DB, and the admin should have an interface
      frontend_handlers = [
          # {
          #     :regex => '^ssh_',
          #     :class => RuoteTrail::SshParticipant,
          #     :options => {}
          # },
          {
              regex: RuoteTrail::ActiveRecord::Participant::PREFIX,
              class: RuoteTrail::ActiveRecord::Participant,
              options: {}
          },
          {   # Default: This one should not be editable by the user
              regex: '.*',
              class: RuoteTrail::Participant,
              options: {}
          }
      ]

      frontend_handlers.select { |h| name =~ /#{h[:regex]}/i }.first
    end

    def self.is_expression?(name)

      RuoteTrail.const_get(name) < RuoteTrail::Expression
      true

    rescue NameError # TODO - low priority - could this be cleaner? avoid exception?
      false

    end

    def self.extract(era, exp)

      case era
        when :present, :past
          exp[1]['fields'] ||= {}
          exp[1]['fields']['params'] ||= {}
          fields = exp[1]['fields'].except('params'),  # TODO to test with a participant with params
          params = exp[1]['fields']['params']          # TODO to test with a participant with params

        when :future # TODO should be load from non-trail to capture on-the-fly process modifications? Like Present?
          fields = {}
          params = exp[1] # Params are directly at [1]
      end

      [ exp[0], fields, params ]
    end
  end
end