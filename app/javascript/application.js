// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// 日付を今日に設定する関数
function setDateToToday(datePrefix) {
  const today = new Date();
  const year = today.getFullYear();
  const month = today.getMonth() + 1; // 0-based なので +1
  const day = today.getDate();
  
  // 年、月、日のセレクトボックスを設定
  const yearSelect = document.getElementById(`task_${datePrefix}_1i`);
  const monthSelect = document.getElementById(`task_${datePrefix}_2i`);
  const daySelect = document.getElementById(`task_${datePrefix}_3i`);
  
  if (yearSelect) yearSelect.value = year;
  if (monthSelect) monthSelect.value = month;
  if (daySelect) daySelect.value = day;
}

// タスク完了機能
function completeTask(taskId) {
  fetch(`/tasks/${taskId}/complete`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => {
    if (response.ok) {
      // ページをリロード
      window.location.reload();
    } else {
      console.error('Server responded with status:', response.status);
      // エラーでもページをリロード（タスクが完了している可能性があるため）
      window.location.reload();
    }
  })
  .catch(error => {
    console.error('Network error:', error);
    // ネットワークエラーでもページをリロード（タスクが完了している可能性があるため）
    window.location.reload();
  });
}

// タスクを未完了に戻す機能（ページ遷移なし）
function incompleteTask(taskId) {
  const taskCard = document.querySelector(`[data-task-id="${taskId}"]`);
  if (!taskCard) return; // タスクカードが存在しない場合は終了
  
  // 重複クリックを防ぐため、ボタンを無効化
  const button = taskCard.querySelector('button[onclick*="incompleteTask"]');
  if (button) button.disabled = true;
  
  fetch(`/tasks/${taskId}/incomplete`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => {
    if (response.ok) {
      // 該当のタスクカードを画面から削除
      taskCard.style.opacity = '0.5';
      taskCard.style.transform = 'translateX(-20px)';
      setTimeout(() => {
        taskCard.remove();
        // 完了タスク数を更新
        updateCompletedTasksCount();
      }, 300);
    } else if (response.status === 404) {
      // タスクが既に削除されている場合、画面からも削除
      taskCard.remove();
      updateCompletedTasksCount();
    }
  })
  .catch(error => {
    console.error('Network error:', error);
    // エラー時もボタンを再有効化
    if (button) button.disabled = false;
  });
}

// タスクを削除する機能（ページ遷移なし）
function deleteTask(taskId) {
  const taskCard = document.querySelector(`[data-task-id="${taskId}"]`);
  if (!taskCard) return; // タスクカードが存在しない場合は終了
  
  // 重複クリックを防ぐため、ボタンを無効化
  const button = taskCard.querySelector('button[onclick*="deleteTask"]');
  if (button) button.disabled = true;
  
  fetch(`/tasks/${taskId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => {
    if (response.ok) {
      // 该当のタスクカードを画面から削除
      taskCard.classList.add('removing');
      setTimeout(() => {
        taskCard.remove();
        // 完了タスク数を更新
        updateCompletedTasksCount();
      }, 300);
    } else if (response.status === 404) {
      // タスクが既に削除されている場合、画面からも削除
      taskCard.remove();
      updateCompletedTasksCount();
    }
  })
  .catch(error => {
    console.error('Network error:', error);
    // エラー時もボタンを再有効化
    if (button) button.disabled = false;
  });
}

// 完了タスク数を更新
function updateCompletedTasksCount() {
  const remainingTasks = document.querySelectorAll('.completed-task-card').length;
  const countElement = document.querySelector('.total-completed strong');
  if (countElement) {
    countElement.textContent = `${remainingTasks}件`;
  }
  
  // タスクが0件になった場合、空の状態を表示
  if (remainingTasks === 0) {
    const completedTasksList = document.querySelector('.completed-tasks-list');
    const noTasksMessage = `
      <div class="no-completed-tasks">
        <div class="empty-state">
          <h3>まだ完了したタスクがありません</h3>
          <p>タスクを完了すると、ここに履歴が表示されます。</p>
          <a href="/" class="btn btn-primary">新しいタスクを作成</a>
        </div>
      </div>
    `;
    if (completedTasksList) {
      completedTasksList.parentElement.innerHTML = noTasksMessage;
    }
  }
}

// グローバルに関数を公開
window.setDateToToday = setDateToToday;
window.completeTask = completeTask;
window.incompleteTask = incompleteTask;
window.deleteTask = deleteTask;
