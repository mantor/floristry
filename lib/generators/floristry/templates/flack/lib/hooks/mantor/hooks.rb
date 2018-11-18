require 'jsonclient'

PROTO='http'
HOST='localhost'
PORT=3000

def hh(path, msg)

  uri = "#{PROTO}://#{HOST}:#{PORT}/hookhandler/#{msg['exid']}/#{path}"
  JSONClient.new.put(uri, { message: msg, })

  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"

  logger.info("OpenSec#hook #{path} for #{msg['exid']}")
end

class LaunchedHook
  def on(msg)

    hh('launched', msg)

    [] # return empty list of new messages
  end
end

class ReturnedHook
  def on(msg)

    hh('returned', msg)

    [] # return empty list of new messages
  end
end

class TerminatedHook

  def on(msg)

    hh('terminated', msg)

    [] # return empty list of new messages
  end
end

class ErrorHook
  def on(msg)

    hh('error', msg)

    [] # return empty list of new messages
  end
end
