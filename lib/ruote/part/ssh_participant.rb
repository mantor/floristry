require 'net/ssh'
class SshParticipant < Ruote::Participant

  def initialize(opts)

    @log = Logger.new(nil)
  end

  def consume(wi)

    regex = /^((\w+)@)?([^:]+)(:(\w+)\.(\w+))?$/ # e.g. 'user@host.mantor.org:os_secfix.json'
    fail ArgumentError.new("syntax is incorrect") unless (match = regex.match wi.params['task'])

    user = match[2].nil? ? 'opensec' : match[2]
    host = match[3]
    modul = match[5]
    format = match[6]
    key = wi.params['key'].nil? ? %w(~/.ssh/id_rsa) : wi.params['key']
    port = wi.params['port'].nil? ? 22 : wi.params['port']

    options = { :keys => key, :keys_only => true, :logger => @log, :port => port }
    out = ''
    err = ''
    Net::SSH.start(host, user, options) do |ssh|
      ssh.open_channel do |channel|
        ch
        annel.exec("fetch #{modul}.#{format}") do |ch, success|
          #abort "could not execute command" unless success # TODO trigger cancel or retry

          ch.on_data do |ch, data|
            out = data
          end

          ch.on_extended_data do |ch, type, data|
            err = data
          end

          ch.on_close do |ch|
            puts "channel is closing!"
          end
        end
      end

      ssh.loop
    end

    wi.fields['stdout'] = out
    wi.fields['stderr'] = err

    reply_to_engine(wi)
  end

  def on_cancel

   # TODO
  end
end