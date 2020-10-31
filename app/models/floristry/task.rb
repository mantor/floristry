module Floristry
  class Task < LeafProcedure

    include TaskProcedureMixin
  end
end

mixin = Floristry.configuration.add_task_behavior
Floristry::Task.send(:include, mixin) if mixin