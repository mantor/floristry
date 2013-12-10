module RuoteTrail
  class Expression
    attr_reader :id, :name, :params, :workitem, :era

    def initialize(id, name, params = {}, workitem = {}, era = :present)

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

    def to_partial_path

      self.class.name.underscore
    end

    # Returns proper Expression type based on name.
    #
    # Anything not a Ruote Expression is considered a Participant Expression, e.g.,
    # if == If, sequence == Sequence, admin == Participant
    #
    def self.factory(id, era = :present, exp = nil)

      name, workitem, params = extract(id, era, exp)

      klass = is_expression?(name.camelize) ? RuoteTrail::const_get(name.camelize) : RuoteTrail::Participant
      klass.new(id, name, params, workitem, era)
    end

    protected

    def self.is_expression?(name)

      RuoteTrail.const_get(name) < RuoteTrail::Expression
      true

    rescue NameError # TODO - low priority - could this be cleaner? avoid exception?
      false

    end

    def self.extract(id, era, exp = nil)

      case era
        when :present
          wi = RuoteKit.storage_participant[id] # TODO error handling - no record
          [
              wi.participant_name,
              wi.fields.except(:params),
              wi.params
          ]
        when :past
          fields = exp[1]['fields'] ? exp[1]['fields'].except(:params): {} # TODO needed? in the past do we really have empty fields
          params = exp[1]['fields']['params'] ? exp[1]['fields']['params'] : {}
          [
              exp[0],
              fields,
              params
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