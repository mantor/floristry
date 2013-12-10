module RuoteTrail

  # ActiveRuote's Leaf Expression - see lib/active_ruote/participant.rb for more
  #
  class Participant < LeafExpression
    attr_accessor :task

    def initialize(id, name, params = {}, workitem = {}, era = :present)

      super(id, name, params, workitem, era)
      params_handler
    end

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors() instance.errors end

    def instance

      @instance ||= @task.camelize.constantize.new(self)
    end

    protected

    def params_handler

      @task = params['task']

      #match = task_param.match /\A(\w+)(\/(\w+))?(#(\w+))?\z/
      #nada, component, model, nada, id = match.captures if match
    end
  end
end