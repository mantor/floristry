require 'jsonclient'

class RestHook
  def initialize(exe, opts, msg)

    @exe = exe
    @opts = opts
    @msg = msg
  end

  def emit(action , msg)

    prot = @exe.unit.conf['pollen_prot'] || 'http'
    host = @exe.unit.conf['pollen_host'] || 'localhost'
    port = @exe.unit.conf['pollen_port'] || '3000'
    path = @exe.unit.conf['pollen_path'] || 'hookhandler'

    uri = "#{prot}://#{host}:#{port}/#{path}/#{msg['exid']}/#{action}"
      # e.g. https://host.org:80/hookhandler/dom-u0-20170514.0383.falibi/returned

    JSONClient.new.put(uri, { message: msg })

    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG
    logger.datetime_format = "%Y-%m-%d %H:%M:%S"

    logger.info("Pollen: #{action} for #{msg['exid']}")
  end
end

actions = ['launched', 'returned', 'terminated', 'error', 'cancel']

actions.each do |a|
  eval "class #{a.capitalize}PollenHook < RestHook
    def on (conf, msg)
      emit(\"#{a}\", msg)
      [] # TODO
    end
  end"
end
