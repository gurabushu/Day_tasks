class AddIndexesToTasks < ActiveRecord::Migration[8.0]
  def change
    add_index :tasks, :status_task
    add_index :tasks, :start_date
    add_index :tasks, :end_date
    add_index :tasks, [:start_date, :end_date]
    add_index :tasks, :completed_at
  end
end
