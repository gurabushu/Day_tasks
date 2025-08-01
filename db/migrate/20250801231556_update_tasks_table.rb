class UpdateTasksTable < ActiveRecord::Migration[8.0]
  def change
    # 既存のカラムを削除
    remove_column :tasks, :task_name, :string if column_exists?(:tasks, :task_name)
    remove_column :tasks, :created_at_daydatetime, :string if column_exists?(:tasks, :created_at_daydatetime)
    remove_column :tasks, :complated_at_day, :datetime if column_exists?(:tasks, :complated_at_day)
    
    # 新しいカラムを追加
    add_column :tasks, :task, :string unless column_exists?(:tasks, :task)
    add_column :tasks, :start_date, :datetime unless column_exists?(:tasks, :start_date)
    add_column :tasks, :end_date, :datetime unless column_exists?(:tasks, :end_date)
    add_column :tasks, :completed_at, :datetime unless column_exists?(:tasks, :completed_at)
    
    # status_taskのデフォルト値を設定
    change_column_default :tasks, :status_task, false
  end
end
