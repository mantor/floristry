require 'jsonclient'

class RestHook
  def initialize(unit)

    @unit = unit
  end

  def emit(action , msg)

    prot = @unit.conf['pollen_prot'] || 'http'
    host = @unit.conf['pollen_host'] || 'localhost'
    port = @unit.conf['pollen_port'] || '3000'
    path = @unit.conf['pollen_path'] || 'hookhandler'

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
