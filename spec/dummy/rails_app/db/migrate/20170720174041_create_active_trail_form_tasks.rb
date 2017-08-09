class CreateActiveTrailFormTasks < ActiveRecord::Migration
  def change
    create_table :active_trail_form_tasks do |t|
      t.string :__feid__
      t.text :__workitem__
      t.string :current_state

      t.text :free_text

      t.timestamps
    end
  end
end
