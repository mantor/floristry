module RuoteTrail
  class Participant < LeafExpression

    include ParticipantExpressionMixin

    def current_state

      self.workitem['current_state']
    end
  end
end