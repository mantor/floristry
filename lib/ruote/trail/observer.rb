module RuoteTrail

  # The observer is responsible to set the current_state via it's hooks (launch, completed, error).
  #
  class Observer < Ruote::Observer

    def initialize(context, options={})

      @context = context

      # TODO
      # unless callback.respond_to?(:archive) do
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
      msg['tree'][1]['current_state'] = 'launched'

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

      t = Time.now
      wi['fields']['replied_at'] = "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC"

      trail = insert_in_tree(doc['trail'], msg['fei']['expid'], wi['fields'])

      new_doc = {
          'type' => 'trail',
          '_id' => msg['fei']['wfid'],
          '_rev' => doc['_rev'],
          'trail' => trail
      }
      @context.storage.put(new_doc)
    end

    # On terminate, move the audit trail outside Ruote's database
    #
    def on_msg_terminated(msg)

      return unless accept?(msg)

      doc = @context.storage.get('trail', msg['wfid'])
      doc['trail'][1]['variables'] = msg['variables']
      doc['trail'][1]['current_state'] = 'completed'
      t = Time.now

      # TODO why do we need to create something new? Why couldn't we use Workflow directly? Workflow.to_h?
      wf = {

          'wfid' => msg['wfid'],
          'name' => msg['workitem']['wf_name'],
          'version' => msg['workitem']['wf_revision'],
          'launched_at' => msg['workitem']['wf_launched_at'],
          'completed_at' => "#{t.utc.strftime('%Y-%m-%d %H:%M:%S')}.#{sprintf('%06d', t.usec)} UTC", # TODO
          'trail' => doc['trail']
      }

      @callback.constantize.archive(wf) # TODO completed workflow should be sent to Rails
      @context.storage.delete(doc)
      # RuoteTrail::OpenSecRequest.new("/workflow/completed/#{msg['wfid']}").send
    end

    def on_msg_error_intercepted(msg)

      doc = @context.storage.get('trail', msg['wfid'])
      doc['trail'][1]['current_state'] = 'error'
      # RuoteTrail::OpenSecRequest.new("/workflow/failed/#{msg['wfid']}").send

      @context.storage.put(doc)
    end

    protected

    # By default, all messages received are recorded.
    #
    # Feel free to override this method in a subclass.
    #
    def accept?(msg) true end

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

  # # Simple class to mock calls to a future OpenSec REST api
  # class OpenSecApi # TODO implement authentication mechanism
  #   def initialize(url)
  #
  #     call_parts = url.split('/')
  #     call_parts.shift if call_parts[0].empty?
  #     @resource = call_parts.shift.camelize.constantize
  #     @action = call_parts.shift
  #     @args = call_parts.first
  #   end
  #
  #   def send
  #
  #     @resource.send(@action, @args)
  #   end
  # end
end