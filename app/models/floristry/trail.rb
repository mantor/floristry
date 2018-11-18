module Floristry
  class Trail < ::ActiveRecord::Base

    serialize :tree, JSON

    scope :active, -> { where(archive: false) }
    scope :archived, -> { where(archive: true) }

    def vars

      tree[4]
    end

    def self.launched(exe)

      t = new
      t.wfid = exe['exid']
      t.name = exe['vars']['name'] || t.wfid
      t.version = '0.1' # TODO
      t.current_state = 'launched'
      t.launched_at = exe['consumed']
      tree = exe['tree']
      tree[3] = exe['payload']
      tree[4] = exe['vars']
      t.tree = tree
      t.save
    end

    # On receive, insert the replied msg at the proper location within
    # the audit tree.
    #
    def self.returned(msg)

      t = find_by_wfid(msg['exid'])
      # todo msg['??']['fields']['replied_at'] = timestamp OR modify flor to handle it?
      t.tree = insert_in_tree(t.tree, msg['nid'], msg['payload'])
      t.save
    end

    def self.terminated(msg)

      t = find_by_wfid(msg['exid'])
      t.current_state = 'terminated'
      t.terminated_at = timestamp
      t.archive = true
      t.save
    end

    def self.error(msg)

      t = find_by_wfid(msg['exid'])
      t.current_state = 'error'
      t.tree = insert_in_tree(t.tree, msg['fei']['expid'], (msg['payload'].nil?) ? {} : msg['payload']['fields'])
      t.save
      raise WorkflowError
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

      t.push payload

      tree
    end
  end
end

mixin = Floristry.configuration.add_trail_behavior
Floristry::Trail.send(:include, mixin) if mixin

class WorkflowError < StandardError
  def initialize(msg='An error occurred in the workflow engine')
    super
  end
end