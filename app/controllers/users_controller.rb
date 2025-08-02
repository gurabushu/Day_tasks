class UsersController < ApplicationController
  def index
    # 現在表示中の月のタスクのみを取得（アクティブなもののみ）
    setup_index_variables
  end

  def completed
    @completed_tasks = Task.completed.order(completed_at: :desc).limit(50)
  end

  private

  def setup_index_variables
    current_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    all_tasks = Task.active.for_month(current_date).to_a # 一度だけクエリ実行
    
    @task = Task.new
    
    # タスクを事前にフィルタリング
    @tasks = all_tasks.reject(&:completed?) # 完了済みは除外
    
    # タスクを日付ごとにグループ化（一度だけ処理）
    @tasks_by_date = {}
    @tasks.each do |task|
      (task.start_date.to_date..task.end_date.to_date).each do |date|
        @tasks_by_date[date] ||= []
        @tasks_by_date[date] << task
      end
    end
    
    # タスク数をメモ化
    @tasks_count = @tasks.size
  end
end
