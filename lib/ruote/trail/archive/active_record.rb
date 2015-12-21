module RuoteTrail
module Archive

  class ActiveRecord
    def self.archive(wf)

      Delayed::Job.where("handler LIKE :query", query: "%#{wf['wfid']}%").each { |job|
        job.delete
        # @todo move this out of here? Hook on msg_terminated
      }

      # wf['wfid'] = wf.delete 'id' # Don't override ActiveRecord surrogate key.
      wfa = WorkflowArchive.new(wf)
      wfa.save
    end
  end

end
end
