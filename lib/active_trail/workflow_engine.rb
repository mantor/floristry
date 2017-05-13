module ActiveTrail
  class WorkflowEngine

    def self.engine() RuoteKit.engine end

    def self.process(exid)

      uri = 'http://localhost:7007/executions'
      json_client = JSONClient.new
      res = json_client.get(uri)

      execs = res.content['_embedded']

      execs.find { |exe|
        exe['exid'] == exid
      }
    end

    def self.processes(opts = {})
      engine.processes(opts)
    end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)

      begin

        # engine.launch(pdef, fields, vars, root_stash)

        json_client = JSONClient.new
        res = json_client.post('http://localhost:7007/message', {
          point: 'launch',
          domain: 'org.mantor',
          tree: pdef }
        )
        exid = res.content['exid']

      rescue Errno::ECONNREFUSED => e

        raise LaunchError.new(e.message)
      end

      # @todo Below is temporary, in anctipation of a launch msg back from flack at some "point"
      # Keep calm and wait for Flor to launch the execution
      sleep(1)

      # It launched. Just create a trail.
      # flack does not return the message with the creation response. Go and grab it
      uri = 'http://localhost:7007/executions'
      json_client = JSONClient.new
      res = json_client.get(uri)

      execs = res.content['_embedded']

      exe = execs.find { |exe|
        exe['exid'] == exid
      }
      ActiveTrail::Trail.launched(exe)


      exid
    end

    def self.register_participant(regex, handler)

      engine.register(regex, handler)
    end

    def self.register_participant_list(plist)

      engine.participant_list= plist
    end

    class LaunchError < Exception
      def initialize(error)

        super("#{error}")
      end
    end
  end
end