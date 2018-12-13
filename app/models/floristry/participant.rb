module Floristry
  class Participant < LeafProcedure

    include ParticipantProcedureMixin
  end
end

mixin = Floristry.configuration.add_participant_behavior
Floristry::Participant.send(:include, mixin) if mixin