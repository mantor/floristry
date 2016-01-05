module RuoteTrail
  class WorkflowArchive < ::ActiveRecord::Base

    # Specify the table name, because the RuoteTrail module namespaces this class, and
    # ActiveRecord table resolution/guess was expecting the table to be named:
    # ruotetrail_workflow_archive
    self.table_name = 'workflow_archives'

    def last_active_at

      completed_at
    end

    alias_attribute :last_active, :last_active_at

    def trail=(t)

      super(t.to_json)
    end

    def trail

      JSON::parse(self[:trail])
    end

    def variables

      trail[1]['variables']
    end
  end
end