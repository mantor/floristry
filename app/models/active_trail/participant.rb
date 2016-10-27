module ActiveTrail
  class Participant < LeafExpression

    # include ExpressionMixin # Can't because active_record use it.
    include ParticipantExpressionMixin

    def current_state

      case era
        when :present
          'open'
        when :past
          'closed'
        else
          ''
      end

    end

    def instance

      self
    end

    def scope (s)

      #TODO: how to deal my scope here ?? I don't have fields nor params.
      s
    end

    def due_at

      # TODO one day, this should be configured via web configs. Also in opensec/app/models/participant_deadline.rb
      # Does this really matter in a context where we expect the process to run in an instant, e.g. SSH Participant??
      Date.today
    end
  end
end