class SetDefaultStatusForTasks < ActiveRecord::Migration[8.0]
  def change
    change_column_default :tasks, :status_task, false
    
    # 既存のnullレコードも更新
    reversible do |dir|
      dir.up do
        Task.where(status_task: nil).update_all(status_task: false)
      end
    end
  end
end
