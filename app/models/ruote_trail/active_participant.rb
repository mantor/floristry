module RuoteTrail

  class ActiveParticipant < LeafExpression

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    def instance

      @instance ||= task.camelize.constantize.find(@id)
    end

    # TODO _active as a Constant? Also used within frontend_handler
    def task

      @name.sub(/^web_/, '')
    end
  end

end