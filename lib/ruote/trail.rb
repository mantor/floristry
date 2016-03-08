require 'ruote/observer'
require 'ruote/workitem'

require 'ruote/trail/observer'
require 'ruote/trail/configuration'
require 'ruote/trail/engine'
require 'ruote/trail/workflow_engine'

require 'forwardable'
require 'active_attr'
require 'active_model'
require 'active_model/mass_assignment_security'
require 'active_model/mass_assignment_security/sanitizer'

module RuoteTrail

  module ExpressionMixin

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    def inactive?()   @era != :present end
    alias_method :disabled?, :inactive?
    alias_method :active?, :is_present?

    def layout() false end

    def to_partial_path() self.class.name.underscore end
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
    def layout() 'layouts/ruote_trail/leaf-expression' end
  end

  module ParticipantExpressionMixin

    include LeafExpressionMixin

    def is_participant?() true end
  end
end