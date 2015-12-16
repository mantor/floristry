<% module_namespacing do -%>
class <%= class_name %> < RuoteTrail::ActiveRecord::Base
  has_one :participant_deadline, as: :timebound
  delegate :due_date, to: :participant_deadline, :allow_nil => true
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
end
<% end -%>