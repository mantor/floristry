module RuoteTrail
module Archive

  class ActiveRecord
    def self.archive(wf)

      wf['wfid'] = wf.delete 'id' # Don't override ActiveRecord surrogate key.
      wfa = WorkflowArchive.new(wf)
      wfa.save
    end
  end

end
end
