class CreateTrails < ActiveRecord::Migration
  def change
    create_table "floristry_trails", force: :cascade do |t|
      t.string   "wfid"
      t.string   "name"
      t.string   "version"
      t.text     "tree"
      t.datetime "launched_at"
      t.datetime "terminated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "archive",       default: false
      t.string   "current_state"
    end
  end
end