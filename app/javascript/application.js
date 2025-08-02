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
  if (!confirm('このタスクを完了しますか？')) {
    return;
  }
  
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
      alert('エラーが発生しました');
    }
  })
  .catch(error => {
    console.error('Error:', error);
    alert('エラーが発生しました');
  });
}

// グローバルに関数を公開
window.setDateToToday = setDateToToday;
window.completeTask = completeTask;
