require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @task = Task.create!(
      task: "テストタスク",
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
  end

  test "should create task with valid parameters" do
    assert_difference('Task.count') do
      post tasks_path, params: {
        task: {
          task: "新しいタスク",
          start_date: Date.current,
          end_date: Date.current + 1.day
        }
      }
    end
    assert_redirected_to root_path
  end

  test "should not create task with invalid parameters" do
    assert_no_difference('Task.count') do
      post tasks_path, params: {
        task: {
          task: "", # 空のタスク名
          start_date: Date.current,
          end_date: Date.current + 1.day
        }
      }
    end
    assert_response :success
    assert_template 'users/index'
  end

  test "should complete task" do
    patch complete_task_path(@task), headers: { 'Accept' => 'application/json' }
    assert_response :success
    @task.reload
    assert @task.completed?
  end

  test "should mark task as incomplete" do
    @task.complete!
    patch incomplete_task_path(@task), headers: { 'Accept' => 'application/json' }
    assert_response :success
    @task.reload
    assert @task.active?
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete task_path(@task), headers: { 'Accept' => 'application/json' }
    end
    assert_response :success
  end

  test "should handle non-existent task gracefully" do
    # 存在しないタスクIDでアクセスした場合のテスト
    # 実際のアプリケーションではエラーページやリダイレクトが発生する可能性がある
    begin
      patch complete_task_path(id: 99999), headers: { 'Accept' => 'application/json' }
      # エラーが発生しなかった場合は404が返される
      assert_response :not_found
    rescue ActiveRecord::RecordNotFound
      # RecordNotFoundが発生した場合は正常
      assert true
    end
  end
end
