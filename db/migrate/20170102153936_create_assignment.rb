class CreateAssignment < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
    	t.boolean "responsible", default: false
    	t.integer "member_id", null: false
    	t.integer "mandate_id", null: false
    	t.index ["member_id", "mandate_id"], name: "index_assignments_on_member_id_and_mandate_id", unique: true
    	t.index ["mandate_id", "member_id"], name: "index_assignments_on_mandate_id_and_member_id", unique: true
    end
  end
end
