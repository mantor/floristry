module RuoteTrail
  class Expression
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

    def active?()     @era == :present end
    def inactive?()   @era != :present end
    # alias inactive? disabled?

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    def layout() false end

    def model?() false end # TODO needed?

    def to_partial_path

      self.class.name.underscore
    end

    # Returns proper Expression type based on name.
    #
    # Anything not a Ruote Expression is considered a Participant Expression, e.g.,
    # if == If, sequence == Sequence, admin == Participant, xyz == Participant
    #
    def self.factory(id, era = :present, exp = nil)

      name, workitem, params = extract(id, era, exp)
      klass_name = name.camelize # TODO CRAPPY camelize
      klass, options = is_expression?(klass_name) ? RuoteTrail::const_get(klass_name) : self.frontend_handler(name) # TODO CRAPPY camelize

      klass.new(id, name, params, workitem, era) # TODO pass options - via *args?
    end

    protected

    def self.frontend_handler(name)

      # TODO this should come from the DB, and the admin should have an interface
      frontend_handlers = [
          {
              :regex => '^ssh_',
              :classname => 'SshParticipant',
              :options => {}
          },
          {
              :regex => '^web_',
              :classname => 'ActiveParticipant', # TODO change to WebParticipant
              :options => {}
          },
          {
              :regex => '.*',
              :classname => 'Participant',
              :options => {}
          }
      ]

      i = 0
      frontend_handlers.each do |h|
        break if name =~ /#{h[:regex]}/i
        i += 1
      end

      # TODO return exception if no frontend handlers match
      # something_something(dark, side)

      klass = RuoteTrail::const_get(frontend_handlers[i][:classname].camelize) # TODO CRAPPY camelize
      options = frontend_handlers[i][:options]

      [klass, options]
    end

    def self.is_expression?(name)

      RuoteTrail.const_get(name) < RuoteTrail::Expression
      true

    rescue NameError # TODO - low priority - could this be cleaner? avoid exception?
      false

    end

    def self.extract(id, era, exp = nil)

      case era
        when :present
          # TODO our own exception? - https://github.com/rails/rails/blob/9aa7c25c28325f62815b6625bdfcc6dd7565165b/activerecord/lib/active_record/errors.rb
          process = RuoteKit.engine.process(id)
          wi = process.stored_workitems[0]
          raise ActiveRecord::RecordNotFound unless wi
          [
              wi.participant_name,
              wi.fields.except(:params),
              wi.params
          ]
        when :past
          exp[1]['fields'] ||= {}
          exp[1]['fields']['params'] ||= {}
          [
              exp[0],
              exp[1]['fields'].except(:params),  # TODO needed? in the past do we really have empty fields
              exp[1]['fields']['params']
          ]
        when :future # TODO should be load from non-trail to capture on-the-fly process modifications? Just like Present?
          [
              exp[0],
              {},
              exp[1] # TODO test this. i believe it's supposed to be exp[1]['params'] ??
          ]
      end
    end
  end
end