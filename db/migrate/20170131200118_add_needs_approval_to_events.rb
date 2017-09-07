class AddNeedsApprovalToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :needs_approval, :boolean
  end
end
