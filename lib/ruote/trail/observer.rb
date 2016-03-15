module RuoteTrail

  # The observer is used by the Workflow frontend to create and update the Trail
  #
  class Observer < Ruote::Observer

    def initialize(context, options={})

      @context = context
      @callback = options['callback']
    end

    def on_msg_launch(msg)

      callback 'launched', msg['wfid'], msg
    end

    def on_pre_msg_receive(msg)

      callback 'replied', msg['fei']['wfid'], msg
    end

    def on_msg_terminated(msg)

      callback 'terminated', msg['wfid'], msg
    end

    def on_msg_error_intercepted(msg)

      callback 'error', msg['wfid'], msg
    end

    def callback(action, wfid, msg)

      RuoteTrail.const_get(@callback).post "/trail/#{action}/#{wfid}", { msg: msg }
    end
  end

  class DummyRestClient # Built so we can use Nestful gem as a drop-in replacement

    def self.post(url, body)

      c = url.split('/')
      RuoteTrail.const_get(c[-3].camelcase).send(c[-2].to_sym, c[-1], body[:msg])

      true
    end
  end
end