
# tasker.rb

class CharlieTasker < Flor::BasicTasker

  def task
    t0 = Time.now
    tstamp = Flor.tstamp(t0)
    payload['charlie_tstamp'] = "#{tstamp} Charlies's thread: #{Thread.current.object_id}"

    reply
  end
end

