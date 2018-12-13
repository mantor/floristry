require 'forwardable'

module Floristry
  class BranchProcedure < Procedure
    include Enumerable
    extend Forwardable
    include BranchProcedureMixin

    attr_reader :children

    def initialize (id, name, payload, vars, era)

      super(id, name, payload, vars, era)

      @children = Array.new

      mixin = Floristry.configuration.add_branch_procedure_behavior
      self.class.send(:include, mixin) if mixin
    end

    def_delegators :@children, :<<, :[], :first, :last, :size, :each, :each_with_index
  end
end