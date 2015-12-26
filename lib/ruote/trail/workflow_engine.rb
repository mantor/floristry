module RuoteTrail
  class WorkflowEngine

    def self.trail(wfid)

      record = engine.storage.get('trail', wfid)

      t = if record && record.key?('trail')
        record['trail']
      else
        WorkflowArchive.find_by(wfid: wfid).trail
      end

      raise ActiveRecord::RecordNotFound unless t

      t
    end

    def self.engine() RuoteKit.engine end

    def self.query(wfid, query = [])

      r = []

      process_info = engine.process(wfid)
      process_info = WorkflowArchive.find_by(wfid: wfid) unless process_info
      raise ActiveRecord::RecordNotFound unless process_info

      query.each do |q|
        r << process_info.send(q)
      end

      r.size == 1 ? r.first : r
    end

    def self.process(wfid) engine.process(wfid) end

    def self.processes(opts = {}) engine.processes(opts) end

    def self.launch(pdef, fields={}, vars={}, root_stash=nil)

      engine.launch(pdef, fields, vars, root_stash)
    end
  end
end