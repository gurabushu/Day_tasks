require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @active_task = Task.create!(
      task: "アクティブタスク",
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
    @completed_task = Task.create!(
      task: "完了タスク",
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
    @completed_task.complete!
  end

  test "should get index" do
    get root_path
    assert_response :success
    assert_template :index
    assert_select 'title', 'Day Tasks'
  end

  test "index should assign necessary variables" do
    get root_path
    assert assigns(:task)
    assert assigns(:tasks)
    assert assigns(:tasks_by_date)
    assert assigns(:tasks_count)
  end

  test "index should only show active tasks" do
    get root_path
    assert_includes assigns(:tasks), @active_task
    assert_not_includes assigns(:tasks), @completed_task
  end

  test "should get completed tasks page" do
    get completed_users_path
    assert_response :success
    assert_template :completed
  end

  test "completed page should show completed tasks" do
    get completed_users_path
    assert assigns(:completed_tasks)
    assert_includes assigns(:completed_tasks), @completed_task
    assert_not_includes assigns(:completed_tasks), @active_task
  end

  test "completed page should order by completed_at desc" do
    # 2つ目の完了タスクを作成
    task2 = Task.create!(
      task: "2つ目の完了タスク",
      start_date: Date.current,
      end_date: Date.current
    )
    sleep(0.1) # 時間差を作る
    task2.complete!

    get completed_users_path
    completed_tasks = assigns(:completed_tasks)
    assert_equal task2, completed_tasks.first
    assert_equal @completed_task, completed_tasks.second
  end
end
