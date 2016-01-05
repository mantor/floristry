module RuoteTrail
  class Participant < LeafExpression

    def is_participant?() true end

    def current_state

      self.workitem['current_state']
    end
  end
end