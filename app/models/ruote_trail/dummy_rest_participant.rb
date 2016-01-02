module RuoteTrail
  NO_SUBID = 'empty_subid' # Replacement for the subid part of a FEID.

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

    def on_cancel

      delete(participant_name, fei)
    end

    protected

    # TODO implement MQ/REST interface
    #
    def push(participant_name, workitem)

      klass = participant_name.sub(/^web_/, '').camelize.constantize
      klass.create(workitem.to_h)
    end

    # TODO implement MQ/REST interface
    #
    def delete(participant_name, fei)

      klass = participant_name.sub(/^web_/, '').camelize.constantize
      fei.h['subid'] = NO_SUBID
      klass.find(fei.sid).destroy
    end
  end
end