# app/controllers/api/tasks_controller.rb
class Api::TasksController < ApplicationController
  def analysis_data
    @completed_tasks = Task.completed.select(
      :id, :task, :start_date, :end_date, :completed_at, :status_task
    ).order(:completed_at)
    
    render json: {
      completed_tasks: @completed_tasks.map do |task|
        {
          id: task.id,
          task_name: task.task,
          start_date: task.start_date,
          end_date: task.end_date,
          completed_at: task.completed_at,
          duration_days: task.duration_days,
          progress_percentage: task.progress_percentage
        }
      end
    }
  end
end