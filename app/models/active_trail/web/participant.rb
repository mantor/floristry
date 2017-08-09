module ActiveTrail::Web

  # This is the frontend participant for web_participants.
  # The corresponding backend participant are models which inherit from ActiveTrail::ActiveRecord::Base
  #
  class Participant < ActiveTrail::Participant

    PREFIX = 'web'
    REGEX = /^#{PREFIX}/

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    def instance # TODO find a better name

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
      ActiveTrail::Web.const_get k
    end
  end
end