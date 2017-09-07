class RenameApprovedAndRemoveEvaluationPhase < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :evaluation_phase
    rename_column :events, :needs_approval, :permission_required
  end
end
