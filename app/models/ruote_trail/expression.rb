module RuoteTrail

  class Expression

    include ExpressionMixin

    attr_reader :id, :name, :params, :workitem, :era

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      @id = id
      @name = name # TODO validate name ...
      @params = params
      @workitem = workitem
      @era = era

      mod = RuoteTrail.configuration.add_expression_behavior
      self.class.send(:include, mod) if mod
    end

    # Returns proper Expression type based on its name.
    #
    # Anything not a Ruote Expression is considered a Participant Expression, e.g.,
    # if == If, sequence == Sequence, admin == Participant, xyz == Participant
    #
    def self.factory(sid, era = :present, exp = nil)

      name, workitem, params = extract(sid, era, exp)
      klass_name = name.camelize

      if is_expression? (klass_name)

        klass = RuoteTrail.const_get(klass_name)
        klass.new(sid, name, params, workitem, era) # TODO pass options - via *args?
      else

        klass, options =  self.frontend_handler(name)
        obj = klass.new(sid, name, params, workitem, era)

        (klass == RuoteTrail::ActiveRecord::Participant) ? obj.instance : obj
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
              :regex => '^web_',
              :class => RuoteTrail::ActiveRecord::Participant,
              :options => {}
          },
          {   # Default: This one should not be editable by the user
              :regex => '.*',
              :class => RuoteTrail::Participant,
              :options => {}
          }
      ]

      handler = frontend_handlers.select { |h| name =~ /#{h[:regex]}/i }.first

      [ handler[:class], handler[:options] ]
    end

    def self.is_expression?(name)

      RuoteTrail.const_get(name) < RuoteTrail::Expression
      true

    rescue NameError # TODO - low priority - could this be cleaner? avoid exception?
      false

    end

    def self.extract(sid, era, exp)

      case era
        when :present
          exp[1]['fields'] ||= {}
          exp[1]['fields']['params'] ||= {}
          [
              exp[0],
              exp[1]['fields'].except('params'),  # TODO to test with a participant with params
              exp[1]['fields']['params']          # TODO to test with a participant with params
          ]

        when :past
          exp[1]['fields'] ||= {}
          exp[1]['fields']['params'] ||= {}
          [
              exp[0],
              exp[1]['fields'].except('params'),
              exp[1]['fields']['params']
          ]

        when :future # TODO should be load from non-trail to capture on-the-fly process modifications? Just like Present?
          [
              exp[0],
              {},
              exp[1] # Params are directly at [1]
          ]
      end
    end
  end
end