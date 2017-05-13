module ActiveTrail
  class WorkflowEngine

    PROTO = 'http'
    HOST = 'localhost'
    PORT = 7007

    def self.engine(res, verb = :get, opts = {})

      begin

        uri = "#{PROTO}://#{HOST}:#{PORT}/#{res}"
        JSONClient.new.send(verb, uri, opts)

      rescue Errno::ECONNREFUSED => e
        raise LaunchError.new(e.message)

      end
    end

    def self.process(exid)

      res = engine('executions')
      execs = res.content['_embedded']

      execs.find { |exe| exe['exid'] == exid }
    end

    def self.processes(opts = {})

      # engine.processes(opts) # TODO
    end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)

      res = engine('message', :post, { point: 'launch', domain: 'org.mantor', tree: pdef } )
      exid = res.content['exid']

      # @todo Below is temporary, in anctipation of a launch msg back from flack at some "point"
      # Keep calm and wait for Flor to launch the execution
      sleep(1)

      # It launched. Just create a trail.
      # flack does not return the message with the creation response. Go and grab it
      process(exid)
      ActiveTrail::Trail.launched(exe)

      exid
    end

    def proceed(wi)

      # res = engine('message', :post, { ... } ) # TODO
    end

    def self.register_participant(regex, handler)

      # engine.register(regex, handler) # TODO
    end

    def self.register_participant_list(plist)

      # engine.participant_list= plist # TODO
    end

    class LaunchError < Exception
      def initialize(error)

        super("#{error}")
      end
    end
  end
end