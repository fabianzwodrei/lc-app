class AddQualificationCachedToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :qualification_cached, :integer, default: 0
  end
end
