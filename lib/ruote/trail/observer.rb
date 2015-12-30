module RuoteTrail

  class Observer < Ruote::Observer

    def initialize(context, options={})

      @context = context

      #unless callback.respond_to?(:archive) do
      #  # error, the callback must respond to the archive method
      #end
      @callback = options['archive']
      @options = options

      @context.storage.add_type('trail')
    end

    # On launch, save tree structure.
    #
    # At that moment, the entire process and every expression involved
    # (e.g. set) are saved along with their params.
    #
    def on_msg_launch(msg)

      return unless accept?(msg)

      msg['tree'][1]['launched_at'] = msg['workitem']['wf_launched_at']

      doc = {
          'type' => 'trail',
          '_id' => msg['wfid'],
          'trail' => msg['tree']
      }

      @context.storage.put(doc)
    end

    # On receive, insert the replied workitem at the proper location within
    # the audit trail.
    #
    def on_pre_msg_receive(msg)

      return unless accept?(msg)

      doc = @context.storage.get('trail', msg['fei']['wfid'])
      wi = msg['workitem']

      trail = insert_in_tree(doc['trail'], msg['fei']['expid'], wi['fields'])

      new_doc = {
          'type' => 'trail',
          '_id' => msg['fei']['wfid'],
          '_rev' => doc['_rev'],
          'trail' => trail
          # TODO add replied time?
      }
      @context.storage.put(new_doc)
    end

    # On terminate, move the audit trail outside Ruote's database
    #
    def on_msg_terminated(msg)

      return unless accept?(msg)

      doc = @context.storage.get('trail', msg['wfid'])
      doc['trail'][1]['variables'] = msg['variables']

      t = Time.now

      # TODO why do we need to create something new? Why couldn't we use Workflow directly? Workflow.to_h?
      wf = {

          'wfid' => msg['wfid'],
          'name' => msg['workitem']['wf_name'],
          'version' => msg['workitem']['wf_revision'],
          'launched_at' => msg['workitem']['wf_launched_at'],
          'completed_at' => "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC",
          'trail' => doc['trail']
      }

      @callback.constantize.archive(wf)

      @context.storage.delete(doc)

      wfid = msg['wfid']
      #TODO This only mocks the real thing, which will be a REST callback to Rails
      RuoteTrail::OpenSecRequest.new("/workflow/complete/#{wfid}").send
    end

    protected

    # By default, all messages received are recorded.
    #
    # Feel free to override this method in a subclass.
    #
    def accept?(msg)

      true
    end

    # Insert hash in a Ruote tree based on an expression id.
    #
    def insert_in_tree(tree, exp, fields)
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

  # Simple class to mock calls to a future OpenSec REST api
  class OpenSecRequest
    def initialize(url)

      call_parts = url.split('/')
      call_parts.shift if call_parts[0].empty?
      @resource = call_parts.shift.camelize.constantize
      @action = call_parts.shift
      @args = call_parts.first
    end

    def send

      @resource.send(@action, @args)
    end
  end
end