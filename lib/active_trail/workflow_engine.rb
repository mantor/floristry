module ActiveTrail
  class WorkflowEngine

    def self.engine() RuoteKit.engine end

    def self.process(wfid) engine.process(wfid) end

    def self.processes(opts = {}) engine.processes(opts) end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)

      begin

        engine.launch(pdef, fields, vars, root_stash)
      rescue Ruote::Reader::Error => e

        raise LaunchError.new(e.message)
      end
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