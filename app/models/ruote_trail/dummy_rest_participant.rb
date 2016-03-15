# This belongs with the Workflow Engine and will be migrated once decoupled with Rails.
#
module RuoteTrail

  # ActiveRecord backend participant
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

    def push(backend_part_name, workitem)

      klass = backend_part_name.sub(WEB_PARTICIPANT_REGEX, '').camelize.constantize
      klass.create(workitem.to_h)
    end

    def delete(backend_part_name, fei)

      klass = backend_part_name.sub(WEB_PARTICIPANT_REGEX, '').camelize.constantize
      fei.h['subid'] = NO_SUBID
      klass.find(fei.sid).destroy
    end
  end
end