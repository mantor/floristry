module RuoteTrail

  # ActiveParticipant Leaf Expression
  #
  # See ruote-trail-on-rails/lib/ruote/trail/active_ruote/base.rb
  #
  class ActiveParticipant < LeafExpression
    attr_accessor :task

    def initialize(id, name, params = {}, workitem = {}, era = :present) # TODO defaults doesn't seems to make sense

      super(id, name, params, workitem, era)
      params_handler(workitem)
    end

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors()

      instance.errors
    end

    def instance

      @instance ||= @task.camelize.constantize.new(self)
    end

    protected

    def params_handler(workitem)

      @task = workitem['params']['ref'].sub(/^web_/, '') # TODO _active as a Constant? Also used within frontend_handler
      #@destination =

      #match = task_param.match /\A(\w+)(\/(\w+))?(#(\w+))?\z/
      #nada, component, model, nada, id = match.captures if match
    end
  end
end