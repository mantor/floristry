module RuoteTrail::ActiveRecord

  # This is the frontend participant for web_participants.
  # The corresponding backend participant are models which inherit from RuoteTrail::ActiveRecord::Base
  #
  class Participant < RuoteTrail::Participant

    PREFIX = 'web_'

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    def instance

      return @instance unless @instance.nil?

      begin
        @instance = klass.find(@id)
      rescue ActiveRecord::RecordNotFound
        @instance = klass.new
      end

      @instance.fei = @fei  # TODO is this needed? could it be immutable?
      @instance.era = @era  # TODO
      @instance
    end

    protected

    def klass

      k = @name.sub(PREFIX, '').camelize
      "RuoteTrail::WebParticipant::#{k}".constantize
    end
  end
end