module Floristry
  class Participant < LeafExpression

    include ParticipantExpressionMixin
  end
end

mixin = Floristry.configuration.add_participant_behavior
Floristry::Participant.send(:include, mixin) if mixin