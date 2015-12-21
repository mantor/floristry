module RuoteTrail
  class WorkflowEngine
    def self.trail(wfid)

      record = engine.storage.get('trail', wfid)
      t = record.key?('trail') ? record['trail'] : WorkflowArchive.find_by(wfid: wfid).trail

      raise ActiveRecord::RecordNotFound unless t

      t
    end

    def self.engine() RuoteKit.engine end

    def self.process(wfid) engine.process(wfid) end

    def self.processes(opts = {}) engine.processes(opts) end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)
      engine.launch(pdef, fields, vars, root_stash)
    end
  end
end