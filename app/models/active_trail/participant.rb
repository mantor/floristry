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

    def due_at

      # TODO one day, this should be configured via web configs. Also in opensec/app/models/participant_deadline.rb
      # Does this really matter here?? Participant that use this frontend handler should be code based and run in an instant.
      Date.today
    end
  end
end