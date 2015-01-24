class WorkflowArchive < ActiveRecord::Base

  def trail=(t)

    super(t.to_json)
  end
end