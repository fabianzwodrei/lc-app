class CreateInvitations < ActiveRecord::Migration[5.0]
  def change
    create_table :invitations do |t|
      t.belongs_to :member, index: true
      t.belongs_to :project, index: true
      t.timestamps
    end
  end
end
