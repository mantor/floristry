require 'ruote/exp/flow_expression'
require 'ruote/exp/ro_timers'

module Ruote::Exp
  class FlowExpression
    protected

    alias :original_consider_timers :consider_timers
    def consider_timers

      original_consider_timers

      ndefs = attribute(:notifications) || ''
      deadline = attribute(:deadline)

      participant_name = self.h.original_tree[0].sub(/^web_/, '').camelize #TODO call common mixin
      wfid = self.applied_workitem.h['fei']['wfid']
      scoped_assets = self.applied_workitem.h['fields']['scope_ids']

      #TODO This should be a restful callback to Rails
      Notifications.enqueue(deadline, participant_name, wfid, scoped_assets, ndefs) unless ndefs.empty?
    end
  end
end