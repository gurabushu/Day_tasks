class UsersController < ApplicationController
  def index
    # 現在表示中の月のタスクのみを取得
    current_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    @tasks = Task.active.for_month(current_date)
    @task = Task.new
    
    # タスクを日付ごとにグループ化してメモ化
    @tasks_by_date = {}
    @tasks.each do |task|
      (task.start_date.to_date..task.end_date.to_date).each do |date|
        @tasks_by_date[date] ||= []
        @tasks_by_date[date] << task
      end
    end
  end

  def completed
    @completed_tasks = Task.completed.order(completed_at: :desc)
  end
end
