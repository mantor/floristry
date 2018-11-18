module Floristry::Ssh

  # This is the frontend participant for ssh_participant.
  #
  class Participant < Floristry::Participant

    PREFIX = 'ssh'
    REGEX = /^#{PREFIX}/
  end
end