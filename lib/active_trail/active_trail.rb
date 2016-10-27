require 'ruote/observer'
require 'ruote/workitem'

# require 'active_trail/observer'
require 'active_trail/configuration'
require 'active_trail/engine'
require 'active_trail/workflow_engine'

require 'forwardable'
require 'active_attr'
require 'active_model'
require 'active_model/mass_assignment_security'
require 'active_model/mass_assignment_security/sanitizer'

module ActiveTrail

  WEB_PARTICIPANT_PREFIX = 'web_'
  SSH_PARTICIPANT_PREFIX = 'ssh_'
  WEB_PARTICIPANT_REGEX = /^#{WEB_PARTICIPANT_PREFIX}/
  SSH_PARTICIPANT_REGEX = /^#{SSH_PARTICIPANT_PREFIX}/
  NO_SUBID = 'empty_subid' # Replacement for the subid part of a FEID.

  module ExpressionMixin

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    def inactive?()   @era != :present end
    alias_method :disabled?, :inactive?
    alias_method :active?, :is_present?

    def layout() false end

    # When mounting an Isolated Engine, the mount path is used as a prefix e.g.
    # route_trail/route_trail/_define.html.erb instead of active_trail/_define.erb
    #
    def to_partial_path()

      @_to_partial_path ||= begin
        p = self.class.name.split('::').drop(1)
        "#{p.map(&:underscore).join('/')}".freeze
      end
    end
  end

  # BranchExpression isn't complete as it requires forwardable for def_delegate
  # and ultimately, @children.
  #
  module BranchExpressionMixin

    def is_leaf?() false end
    def is_branch?() true end
    def is_participant?() false end
  end

  module LeafExpressionMixin

    def is_leaf?() true end
    def is_branch?() false end
    def is_participant?() false end
    def layout() 'layouts/active_trail/leaf-expression' end
  end

  module ParticipantExpressionMixin

    include LeafExpressionMixin

    def is_participant?() true end
  end
end