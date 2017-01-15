module ActiveTrail
  class WorkflowEngine

    def self.engine() RuoteKit.engine end

    def self.process(wfid) engine.process(wfid) end

    def self.processes(opts = {}) engine.processes(opts) end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)

      # Silence Ruote Exception, in Anticipation that the WorkflowEngine will be a remote service.
      begin

        engine.launch(pdef, fields, vars, root_stash)
      rescue

        raise LaunchError
      end
    end

    def self.register_participant(regex, handler)

      engine.register(regex, handler)
    end

    def self.register_participant_list(plist)

      engine.participant_list= plist
    end

    class LaunchError < Exception
      def initialize()
        super('cannot launch process')
      end
    end
  end
end