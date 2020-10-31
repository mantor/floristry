module Floristry::Ssh

  # This is the frontend for ssh_task.
  #
  class Task < Floristry::Task

    PREFIX = 'ssh'
    REGEX = /^#{PREFIX}/
  end
end