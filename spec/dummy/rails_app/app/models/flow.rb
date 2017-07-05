class Flow < ActiveRecord::Base
  validates :name, presence: true
  validates :definition, presence: true

  def launch

    ActiveTrail::WorkflowEngine.launch("\n#{definition}")
  end
end
