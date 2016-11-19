module ActiveTrail
  class Participant < LeafExpression

    include ParticipantExpressionMixin
  end
end

mixin = ActiveTrail.configuration.add_participant_behavior
ActiveTrail::Participant.send(:include, mixin) if mixin