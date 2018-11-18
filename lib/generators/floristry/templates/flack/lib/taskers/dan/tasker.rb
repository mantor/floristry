
# tasker.rb

class DanTasker < Flor::BasicTasker

  def task
    t0 = Time.now
    tstamp = Flor.tstamp(t0)
    payload['dan_tstamp'] = "#{tstamp} Dan's thread: #{Thread.current.object_id}"

    reply
  end
end

