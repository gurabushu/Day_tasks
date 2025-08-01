class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :task
      t.datetime :start_date      # 実行開始日
      t.datetime :end_date        # 実行終了日
      t.datetime :completed_at    # 完了日時
      t.boolean :status_task, default: false

      t.timestamps
    end
  end
end
