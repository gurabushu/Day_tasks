class UsersController < ApplicationController
  def index
    @tasks = Task.active.includes(:completed_at)
    @task = Task.new
  end

  def completed
    @completed_tasks = Task.completed.order(completed_at: :desc)
  end
end
