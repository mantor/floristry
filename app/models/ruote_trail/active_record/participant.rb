module RuoteTrail::ActiveRecord

  class Participant < LeafExpression

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    def instance

      @instance unless @instance.nil?
      begin
        @instance = task.camelize.constantize.find(@id)
      rescue
        @instance = task.camelize.constantize.new
      end

      @instance.era = @era
      @instance
    end

    # TODO _active as a Constant? Also used within frontend_handler
    def task

      @name.sub(/^web_/, '')
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