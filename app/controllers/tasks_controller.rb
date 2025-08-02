require 'csv'

class TasksController < ApplicationController
  before_action :set_task, only: [:complete, :incomplete, :destroy]

  def index
    @tasks = Task.active
    @completed_tasks = Task.completed
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    
    if @task.save
      redirect_to root_path, notice: 'タスクが登録されました'
    else
      # バリデーションエラー時に必要な変数を設定
      setup_index_variables
      render 'users/index'
    end
  end

  def complete
    @task.complete!
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'タスクを完了しました' }
      format.json { head :ok }
    end
  end

  def incomplete
    @task.incomplete!
    respond_to do |format|
      format.html { 
        # 完了タスク一覧から戻された場合はホームにリダイレクト
        if request.referer&.include?('completed')
          redirect_to root_path, notice: 'タスクを未完了に戻しました'
        else
          redirect_to root_path, notice: 'タスクを未完了に戻しました'
        end
      }
      format.json { head :ok }
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { 
        # 完了タスク一覧から削除された場合は完了一覧にリダイレクト
        if request.referer&.include?('completed')
          redirect_to completed_users_path, notice: 'タスクを削除しました'
        else
          redirect_to root_path, notice: 'タスクを削除しました'
        end
      }
      format.json { head :ok }
    end
  end
  
  private

  def set_task
    @task = Task.find(params[:id])
  end
  
  def task_params
    params.require(:task).permit(:task, :start_date, :end_date)
  end

  def setup_index_variables
    current_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    all_tasks = Task.active.for_month(current_date).to_a
    
    @task ||= Task.new # 既に@taskがある場合は上書きしない
    
    # タスクを事前にフィルタリング
    @tasks = all_tasks.reject(&:completed?)
    
    # タスクを日付ごとにグループ化（明示的に初期化）
    @tasks_by_date = {}
    @tasks.each do |task|
      next unless task.start_date && task.end_date # 日付が存在する場合のみ処理
      (task.start_date.to_date..task.end_date.to_date).each do |date|
        @tasks_by_date[date] ||= []
        @tasks_by_date[date] << task
      end
    end
    
    # タスク数をメモ化
    @tasks_count = @tasks.size
  end
end
