class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :incomplete]

  def index
    @tasks = Task.active
    @completed_tasks = Task.completed
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    
    if @task.save
      redirect_to users_path, notice: 'タスクが登録されました'
    else
      @tasks = Task.active
      @completed_tasks = Task.completed
      render 'users/index'
    end
  end

  def complete
    @task.complete!
    redirect_to users_path, notice: 'タスクを完了しました'
  end

  def incomplete
    @task.incomplete!
    redirect_to users_path, notice: 'タスクを未完了に戻しました'
  end

  def destroy
    @task.destroy
    redirect_to users_path, notice: 'タスクを削除しました'
  end
  
  private

  def set_task
    @task = Task.find(params[:id])
  end
  
  def task_params
    params.require(:task).permit(:task, :start_date, :end_date)
  end
end
