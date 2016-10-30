module ActiveTrail::SSH

  # This is the frontend participant for ssh_participant.
  # TODO it's currently tuned to SshPkgAudit implementation
  #
  class Participant < ActiveTrail::Participant
    PREFIX = 'ssh_'

    def scope

      s = ''
      if params['target'].nil?

        fields['scoped'].each {|h| s << h[1]['name']}
      else

        fields['scoped'].select{|k,v| v['tags'].include?(params['target']) }.each {|h| s << h[1]['name']}
      end

      s
    end
  end
end