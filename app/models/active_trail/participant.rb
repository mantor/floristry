module ActiveTrail
  class Participant < LeafExpression

    # include ExpressionMixin # Can't because active_record use it.
    include ParticipantExpressionMixin

    def current_state

      self.fields['current_state']
    end
  end
end