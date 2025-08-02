require 'csv'

class UsersController < ApplicationController
  def index
    # 現在表示中の月のタスクのみを取得（アクティブなもののみ）
    setup_index_variables
  end

  def completed
    @completed_tasks = Task.completed.order(completed_at: :desc).limit(50)
  end

  def analysis
    @completed_tasks = Task.completed.order(:completed_at)
    
    @analysis_stats = {
      total_completed: @completed_tasks.count,
      avg_duration: calculate_average_duration(@completed_tasks),
      monthly_completions: calculate_monthly_completions(@completed_tasks),
      weekly_completions: calculate_weekly_completions(@completed_tasks),
      top_habits: @completed_tasks.group(:task).count.sort_by(&:last).reverse.first(10),
      duration_distribution: calculate_duration_distribution(@completed_tasks),
      completion_trends: calculate_completion_trends(@completed_tasks)
    }

    # Chart.js用のデータ形式に変換
    @chart_data = prepare_chart_data(@analysis_stats)

    respond_to do |format|
      format.html
      format.csv { send_data tasks_to_csv(@completed_tasks), filename: "task_analysis_#{Date.current}.csv" }
    end
  end

  private

  def calculate_average_duration(tasks)
    return 0 if tasks.empty?
    total_duration = tasks.sum(&:duration_days)
    (total_duration.to_f / tasks.count).round(1)
  end

  def calculate_monthly_completions(tasks)
    tasks.group_by { |task| 
      task.completed_at&.beginning_of_month 
    }.transform_values(&:count).compact
  end

  def calculate_weekly_completions(tasks)
    tasks.group_by { |task| 
      task.completed_at&.beginning_of_week 
    }.transform_values(&:count).compact
  end

  def calculate_duration_distribution(tasks)
    tasks.group_by { |task|
      case task.duration_days
      when 1..7
        "1週間以内"
      when 8..14
        "2週間以内" 
      when 15..30
        "1ヶ月以内"
      when 31..60
        "2ヶ月以内"
      else
        "2ヶ月超"
      end
    }.transform_values(&:count)
  end

  def calculate_completion_trends(tasks)
    last_30_days = 30.days.ago.to_date..Date.current
    last_30_days.map { |date|
      [date, tasks.count { |task| task.completed_at&.to_date == date }]
    }.to_h
  end

  def prepare_chart_data(stats)
    {
      monthly_chart: {
        type: 'line',
        data: {
          labels: stats[:monthly_completions].keys.map { |date| date&.strftime("%Y年%m月") },
          datasets: [{
            label: '月別完了数',
            data: stats[:monthly_completions].values,
            borderColor: 'rgb(75, 192, 192)',
            backgroundColor: 'rgba(75, 192, 192, 0.1)',
            borderWidth: 2,
            pointBackgroundColor: 'rgb(75, 192, 192)',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 5,
            fill: false,
            tension: 0.3
          }]
        },
        options: {
          title: '月別完了タスク数の推移'
        }
      },
      habits_chart: {
        type: 'line',
        data: {
          labels: stats[:top_habits].map(&:first),
          datasets: [{
            label: '完了回数',
            data: stats[:top_habits].map(&:last),
            borderColor: 'rgb(54, 162, 235)',
            backgroundColor: 'rgba(54, 162, 235, 0.1)',
            borderWidth: 2,
            pointBackgroundColor: 'rgb(54, 162, 235)',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 5,
            fill: false,
            tension: 0.3
          }]
        },
        options: {
          title: '人気の習慣推移'
        }
      },
      duration_chart: {
        type: 'line',
        data: {
          labels: stats[:duration_distribution].keys,
          datasets: [{
            label: '実行期間分布',
            data: stats[:duration_distribution].values,
            borderColor: 'rgb(255, 205, 86)',
            backgroundColor: 'rgba(255, 205, 86, 0.1)',
            borderWidth: 2,
            pointBackgroundColor: 'rgb(255, 205, 86)',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 5,
            fill: false,
            tension: 0.3
          }]
        },
        options: {
          title: '実行期間別分布'
        }
      },
      trends_chart: {
        type: 'line',
        data: {
          labels: stats[:completion_trends].keys.map { |date| date.strftime("%m/%d") },
          datasets: [{
            label: '日別完了数',
            data: stats[:completion_trends].values,
            borderColor: 'rgb(255, 99, 132)',
            backgroundColor: 'rgba(255, 99, 132, 0.1)',
            borderWidth: 2,
            pointBackgroundColor: 'rgb(255, 99, 132)',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4,
            fill: false,
            tension: 0.3
          }]
        },
        options: {
          title: '過去30日間の完了トレンド'
        }
      }
    }
  end

  def setup_index_variables
    current_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    all_tasks = Task.active.for_month(current_date).to_a

    @task = Task.new
    @tasks = all_tasks.reject(&:completed?)

    @tasks_by_date = {}
    @tasks.each do |task|
      (task.start_date.to_date..task.end_date.to_date).each do |date|
        @tasks_by_date[date] ||= []
        @tasks_by_date[date] << task
      end
    end

    @tasks_count = @tasks.size
  end

  def tasks_to_csv(tasks)
    CSV.generate(headers: true) do |csv|
      csv << ['id', 'task_name', 'start_date', 'end_date', 'completed_at', 'duration_days', 'progress_percentage']

      tasks.each do |task|
        csv << [
          task.id,
          task.task,
          task.start_date,
          task.end_date,
          task.completed_at,
          task.duration_days,
          task.progress_percentage
        ]
      end
    end
  end
end
