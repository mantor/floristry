module RuoteTrail

  # ActiveRecord backend participant - TODO to move out of RuoteTrail !!
  #
  # Once we remove Ruote-kit, change this for a real Restful HTTP client - e.g. Ruote-Jig
  #
  class DummyRestParticipant
    include Ruote::LocalParticipant

    def initialize(options)

      @options = options
    end

    def do_not_thread() true end

    def on_workitem

      push( participant_name, workitem )

      # proceed if forget
    end

    # Removes the document/workitem from the storage.
    # Warning: this method is called by the engine (worker), i.e. not by you.
    #
    # def on_cancel
    #
    #   doc = fetch(fei)
    #
    #   return unless doc
    #
    #   r = @context.storage.delete(doc) # TODO remove from ActiveRecord
    # end

    protected

    # TODO implement MQ/REST interface
    #
    def push(participant_name, workitem)

      klass = participant_name.sub(/^web_/, '').camelize.constantize # Temporary until migrated to frontend - mq/rest
      klass.create(workitem.to_h)
    end
  end

end