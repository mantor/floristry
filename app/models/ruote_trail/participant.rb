module RuoteTrail
  class Participant < LeafExpression

    include ParticipantExpressionMixin

    def current_state

      self.fields['current_state']
    end
  end
end