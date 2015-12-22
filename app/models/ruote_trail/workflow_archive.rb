module RuoteTrail
class WorkflowArchive < ::ActiveRecord::Base
  #Specify the table name, because the RuoteTrail module namespaces this class, and
  #ActiveRecord table resolution/guess was expecting the table to be named:
  # ruotetrail_workflow_archive
  self.table_name = 'workflow_archives'

  def last_active_at

    completed_at
  end

  def trail=(t)

    super(t.to_json)
  end

  def trail

    JSON::parse(self[:trail])
  end
end
end