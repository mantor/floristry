require 'net/ssh'
class SshTasker < Flor::BasicTasker

  def task

    if payload['target'].nil?

      hosts = payload['scoped']
    else

      hosts = payload['scoped'].select{|k,v| v['tags'].include?(payload['target']) }
    end

    # # TODO default user and key and port should be manipulable via web &&|| extracted to a config
    user = attd['user'].nil? ? 'mantor' : attd['user']
    key = attd['key'].nil? ? %w(~/.ssh/id_rsa) : attd['key'] # TODO none by default - let the lib choose
    port = attd['port'].nil? ? 22 : attd['port']
    command = attd['command'].nil? ? 'fetch' : attd['command']
    #
    @log = Logger.new(nil)
    options = { keys: key, keys_only: true, non_interactive: true, logger: @log, port: 22 }
    out = ""
    err = ""

    hosts.each do |h|

      begin
        Net::SSH.start(h[1]['name'], user, options) do |ssh|
          ssh.open_channel do |channel|
            channel.exec(command) do |ch, success|
              abort "could not execute command" unless success # TODO trigger cancel or retry

              ch.on_data do |ch, data|
                out << data
              end

              ch.on_extended_data do |ch, type, data|
                err << data
              end

              ch.on_close do |ch|
                puts "channel is closing!"
              end
            end
          end

          ssh.loop
        end
      rescue Exception => exception
        err << exception.message
      end

    end

    payload['stdout'] = out
    payload['stderr'] = err

    reply
  end

  def on_cancel

    # TODO
  end
end