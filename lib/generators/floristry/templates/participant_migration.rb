class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :active_trail_<%= table_name %> do |t|
      t.string :__feid__
      t.text :__msg__
      t.string :current_state
<% attributes.each do |attribute| -%>
<% if attribute.password_digest? -%>
t.string :password_digest<%= attribute.inject_options %>
<% else -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% end -%>
<% if options[:timestamps] %>
      t.timestamps
<% end -%>
    end
<% attributes_with_index.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
  end
end
