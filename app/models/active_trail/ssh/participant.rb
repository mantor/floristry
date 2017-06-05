module ActiveTrail::Ssh

  # This is the frontend participant for ssh_participant.
  #
  class Participant < ActiveTrail::Participant

    PREFIX = 'ssh'
    REGEX = /^#{PREFIX}/
  end
end