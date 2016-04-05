module ActiveTrail

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

      ActiveTrail.const_get(@callback).post "/trail/#{action}/#{wfid}", { msg: msg }
    end
  end

  class DummyRestClient # Built so we can use Nestful gem as a drop-in replacement

    def self.post(url, body)

      c = url.split('/')
      ActiveTrail.const_get(c[-3].camelcase).send(c[-2].to_sym, c[-1], body[:msg])

      true
    end
  end
end

# TODO should we use a statemachine?
# class WorkflowStateMachine
#   include Statesman::Machine
#   include Statesman::Events
#
#   state :started, initial: true
#   state :completed
#   state :completed_with_errors
#   state :error
#
#   event :complete do
#     transition from: :started,  to: :completed
#   end
#
#   event :complete_with_errors do
#     transition from: :started,  to: :completed_with_errors
#   end
#
#   event :error do
#     transition from: :started,  to: :error
#   end
#
#   def current_state= state
#     @current_state = state
#   end
# end