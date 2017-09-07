class ReplaceWhenByDate < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :when
  end
end
