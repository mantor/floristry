require 'forwardable'

module Floristry
  class BranchProcedure < Procedure
    include Enumerable
    extend Forwardable
    include BranchProcedureMixin

    attr_reader :children

    def initialize (id, name, atts, payload, era)

      super(id, name, atts, payload, era)

      @children = Array.new

      mixin = Floristry.configuration.add_branch_procedure_behavior
      self.class.send(:include, mixin) if mixin
    end

    def_delegators :@children, :<<, :[], :first, :last, :size, :each, :each_with_index
  end
end