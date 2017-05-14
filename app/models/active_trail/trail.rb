module ActiveTrail
  class Trail < ::ActiveRecord::Base

    serialize :tree, JSON

    scope :active, -> { where(archive: false) }
    scope :archived, -> { where(archive: true) }

    # On launch, save tree structure.
    #
    # At that moment, the entire process and every expression involved
    # are saved along with their params but there's no workitem.
    #
    # def self.launched(wfid, msg)
    #
    #   t = new
    #   t.wfid = wfid
    #   t.name = msg['workitem']['wf_name']
    #   t.version = msg['workitem']['wf_revision']
    #   t.current_state = 'launched'
    #   t.launched_at = msg['workitem']['wf_launched_at']
    #   msg['tree'][1]['fields'] = msg['workitem']['fields']
    #   msg['tree'][1]['params'] = msg['variables'].select { |k, v| !v.is_a?(Array) } # TODO This is BS but working (tm)
    #   t.tree = msg['tree']
    #   t.save
    # end

    def self.launched(exe)

      t = new
      t.wfid = exe['exid']
      t.name = 'Test' # TODO
      t.version = '0.1' # TODO
      t.current_state = 'launched'
      t.launched_at = exe['consumed'] #TODO check timezone / timestamp format
      t.tree = exe['tree']
      t.save
    end

    # On receive, insert the replied workitem at the proper location within
    # the audit tree.
    #
    def self.returned(msg)

      t = find_by_wfid(msg['exid'])
      # todo msg['workitem']['fields']['replied_at'] = timestamp
      t.tree = insert_in_tree(t.tree, msg['nid'], msg['payload'])
      t.save
    end

    def self.terminated(msg)

      t = find_by_wfid(msg['exid'])
      t.current_state = 'completed'
      t.completed_at = timestamp
      t.archive = true
      t.save
    end

    def self.error(msg)

      t = find_by_wfid(msg['exid'])
      t.current_state = 'error'
      t.tree = insert_in_tree(t.tree, msg['fei']['expid'], (msg['workitem'].nil?) ? {} : msg['workitem']['fields'])
      # TODO delete jobs?
      t.save
    end

    def self.timestamp

      t = Time.now
      "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC"
    end

    protected

    # Insert hash in a workflow tree based on an expression id.
    #
    def self.insert_in_tree(tree, nid, payload)
      t = [tree]
      nid = nid.split('_')

      i = 0
      while i < nid.size - 1
        t = t[nid[i].to_i][1] # subtree
        i += 1
      end
      t = t[nid[i].to_i] # last has no subtree

      t[1][0].push payload

      tree
    end
  end
end

mixin = ActiveTrail.configuration.add_trail_behavior
ActiveTrail::Trail.send(:include, mixin) if mixin