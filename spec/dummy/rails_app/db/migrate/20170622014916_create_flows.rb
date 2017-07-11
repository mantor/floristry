class CreateFlows < ActiveRecord::Migration
  def change
    create_table :flows do |t|
      t.string :name
      t.text :definition

      t.timestamps null: false
    end
  end
end
