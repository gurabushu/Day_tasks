require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @task = Task.new(
      task: "読書する",
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
  end

  test "should be valid with valid attributes" do
    assert @task.valid?
  end

  test "should require task name" do
    @task.task = nil
    assert_not @task.valid?
    assert_includes @task.errors[:task], "を入力してください"
  end

  test "should require start_date" do
    @task.start_date = nil
    assert_not @task.valid?
    assert_includes @task.errors[:start_date], "を入力してください"
  end

  test "should require end_date" do
    @task.end_date = nil
    assert_not @task.valid?
    assert_includes @task.errors[:end_date], "を入力してください"
  end

  test "end_date should be after or equal to start_date" do
    @task.end_date = @task.start_date - 1.day
    assert_not @task.valid?
  end

  test "should be active by default" do
    @task.save
    assert @task.active?
    assert_not @task.completed?
  end

  test "complete! should mark task as completed" do
    @task.save
    @task.complete!
    assert @task.completed?
    assert_not @task.active?
    assert @task.completed_at.present?
  end

  test "incomplete! should mark task as active" do
    @task.save
    @task.complete!
    @task.incomplete!
    assert @task.active?
    assert_not @task.completed?
    assert @task.completed_at.nil?
  end

  test "duration_days should calculate correctly" do
    @task.start_date = Date.new(2025, 1, 1)
    @task.end_date = Date.new(2025, 1, 3)
    assert_equal 3, @task.duration_days
  end

  test "scopes should work correctly" do
    active_task = Task.create!(task: "Active", start_date: Date.current, end_date: Date.current)
    completed_task = Task.create!(task: "Completed", start_date: Date.current, end_date: Date.current)
    completed_task.complete!

    assert_includes Task.active, active_task
    assert_not_includes Task.active, completed_task
    assert_includes Task.completed, completed_task
    assert_not_includes Task.completed, active_task
  end
end
