class AddEvaluationPhaseAndArchiveToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :evaluation_phase, :boolean
    add_column :events, :archive, :boolean
  end
end
