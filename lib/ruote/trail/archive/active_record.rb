module RuoteTrail
module Archive

  class ActiveRecord
    def self.archive(wf)

      Delayed::Job.where("handler LIKE '%procedure%' AND handler LIKE :query", query: "%#{wf['wfid']}%").each { |job|
        job.delete
        # @todo move this out of here?
        Rails.logger.info("Deleting JOB")
        Rails.logger.info("#{job.inspect}")
      }

      # wf['wfid'] = wf.delete 'id' # Don't override ActiveRecord surrogate key.
      wfa = WorkflowArchive.new(wf)
      wfa.save
    end
  end

end
end
