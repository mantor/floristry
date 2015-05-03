module RuoteTrail
class WorkflowArchive < ActiveRecord::Base
  self.table_name = 'workflow_archives'
  def trail=(t)

    super(t.to_json)
  end
end
end