require 'jsonclient'
class WebTasker < Flor::BasicTasker

  def task

    payload['post_tstamp'] = Time.now.to_s

    JSONClient.new.post('http://localhost:3000/webtask/create', { message: message })
  end

  def on_cancel

    # TODO
  end
end
