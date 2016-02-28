# This belongs in the Workflow Engine and will be migrated once decoupled with Rails.
#
require 'ruote/exp/flow_expression'
require 'ruote/exp/ro_timers'

module Ruote::Exp
  class FlowExpression
    protected

    alias :original_consider_timers :consider_timers
    def consider_timers

      original_consider_timers

      return unless attribute(:notifications)

      params = Hash.new
      params[:name] = self.h.original_tree[0].sub(/^web_/, '').camelize #TODO call common mixin
      params[:wfid] = self.applied_workitem.h['fei']['wfid']
      params[:assets] = self.applied_workitem.h['fields']['scope_ids']

      callback(attribute(:notifications), attribute(:deadline), params)
    end

    # This will eventually be a RESTful call from Ruote to Rails
    def callback(ndefs, deadline, params)

      Notification::Jobber.schedule(Notification::ParticipantJob, ndefs, deadline, params)
    end
  end
end