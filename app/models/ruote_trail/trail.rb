module RuoteTrail
  class Trail < ::ActiveRecord::Base

    serialize :tree, JSON

    # default_scope { where(archive: false) }
    scope :active, -> { where(archive: false) }
    scope :archived, -> { where(archive: true) }

    # Specify the table name, because the RuoteTrail module namespaces this class, and
    # ActiveRecord table resolution/guess was expecting the table to be named:
    # ruotetrail_workflow_archive
    # TODO it's OK to have it under ruotetrail
    self.table_name = 'trail'

    # On launch, save tree structure.
    #
    # At that moment, the entire process and every expression involved
    # are saved along with their params but there's no workitem.
    #
    def self.launched(wfid, msg)

      t = new
      t.wfid = wfid
      t.name = msg['workitem']['wf_name']
      t.version = msg['workitem']['wf_revision']
      t.current_state = 'launched'
      t.launched_at = msg['workitem']['wf_launched_at']
      msg['tree'][1]['fields'] = msg['workitem']['fields']
      msg['tree'][1]['params'] = msg['variables'].select { |k, v| !v.is_a?(Array) } # TODO This is BS but working (tm)
      t.tree = msg['tree']
      t.save
    end

    # On receive, insert the replied workitem at the proper location within
    # the audit tree.
    #
    def self.replied(wfid, msg)

      t = find_by_wfid(wfid)
      msg['workitem']['fields']['replied_at'] = timestamp
      t.tree = insert_in_tree(t.tree, msg['fei']['expid'], msg['workitem']['fields'])
      t.save
    end

    def self.terminated(wfid, msg)

      t = find_by_wfid(wfid)
      t.current_state = 'completed'
      t.completed_at = now
      t.archive = true
      # TODO delete jobs?
      t.save
    end

    def self.error(wfid, msg)

      t = find_by_wfid(wfid)
      t.current_state = 'error'
      t.tree = insert_in_tree(t.tree, msg['fei']['expid'], msg['workitem']['fields'])
      # TODO delete jobs?
      t.save
    end

    def self.timestamp

      t = Time.now
      "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC"
    end

    protected

    # Insert hash in a Ruote tree based on an expression id.
    #
    def self.insert_in_tree(tree, exp, fields)
      t = [tree]
      exp = exp.split('_')

      i = 0
      while i < exp.size - 1
        t = t[exp[i].to_i][2] # subtree
        i += 1
      end
      t = t[exp[i].to_i] # last has no subtree

      t[1]['fields'] = fields

      tree
    end
  end
end