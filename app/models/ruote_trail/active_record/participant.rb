module RuoteTrail::ActiveRecord

  class Participant < RuoteTrail::Participant

    PREFIX = '^web_'

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    def instance

      return @instance unless @instance.nil?

      begin
        @instance = task.camelize.constantize.find(@id)

      rescue
        @instance = task.camelize.constantize.new
        @instance.fei = @fei
      end

      @instance.era = @era
      @instance
    end

    def task

      @name.sub(/#{PREFIX}/, '')
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