module_namespacing do
  class class_name < ActiveTrail::ActiveRecord::Base
     attributes.select(&:reference?).each do |attribute|
      belongs_to : attribute.name, polymorphic: true if attribute.polymorphic?
    end
    has_one :participant_deadline, as: :timebound
    delegate :due_at, to: :participant_deadline, :allow_nil => true
  end
end