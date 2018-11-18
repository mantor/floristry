class Flow < ActiveRecord::Base
  validates :name, presence: true
  validates :definition, presence: true

  def launch

    Floristry::WorkflowEngine.launch("\n#{definition}", {name: name})
  end
end
