class MoveAnnotationIdToMembers < ActiveRecord::Migration[5.0]
  def up
  	add_column :members, :annotation_id, :integer
  	execute "UPDATE members m SET annotation_id = (SELECT a.id FROM annotations a WHERE a.member_id = m.id);"
  	remove_column :annotations, :member_id
  end

  def down
	add_column :annotations, :member_id, :integer
  	execute "UPDATE annotations a SET member_id = (SELECT m.id FROM members m WHERE m.annotations_id = a.id);"
  	remove_column :members, :annotation_id
  end
end
