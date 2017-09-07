class AddsPublicInfosToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :public_infos, :text
  	add_column :members, :phone, :string
  end
end
