require 'flor'
require 'jsonclient'

require 'floristry/configuration'
require 'floristry/engine'
require 'floristry/workflow_engine'

require 'forwardable'
require 'active_attr'
require 'active_model'
require 'active_model/mass_assignment_security'

module Floristry

  module ProcedureMixin

    attr_accessor :era

    def is_past?()    @era == :past    end
    def is_present?() @era == :present end
    def is_future?()  @era == :future  end

    def inactive?()   @era != :present end
    alias_method :disabled?, :inactive?
    alias_method :active?, :is_present?

    def layout() false end

    def to_partial_path()

      @_to_partial_path ||= begin
        p = self.class.name.split('::').drop(1)
        "#{p.map(&:underscore).join('/')}".freeze
      end
    end

    def as_variable_name()

      if self.class.ancestors.include? (Floristry::Participant)
        'participant'
      else
        "flo#{name.capitalize}"
      end
    end
  end

  # BranchProcedure isn't complete as it requires forwardable for def_delegate
  # and ultimately, @children.
  #
  module BranchProcedureMixin

    def is_leaf?() false end
    def is_branch?() true end
    def is_participant?() false end
  end

  module LeafProcedureMixin

    include ProcedureMixin

    def is_leaf?() true end
    def is_branch?() false end
    def is_participant?() false end
    def instance() self end
    def current_state() 'in_progress' end
    def layout() 'layouts/floristry/leaf-procedure' end
  end

  module ParticipantProcedureMixin

    def is_participant?() true end
    def due_at() nil end
    def instance() self end

    def current_state

      case era
        when :future
          'upcoming'
        when :present
          'open'
        when :past
          'closed'
        else
          ''
      end
    end
  end
end