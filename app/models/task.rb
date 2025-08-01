class Task < ApplicationRecord
  # バリデーション
  validates :task, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  
  # スコープ
  scope :active, -> { where(status_task: false) }
  scope :completed, -> { where(status_task: true) }
  scope :for_date, ->(date) { where(start_date: date.beginning_of_day..date.end_of_day) }
  scope :in_period, ->(start_date, end_date) { where('start_date <= ? AND end_date >= ?', end_date, start_date) }
  
  # メソッド
  def complete!
    update!(status_task: true, completed_at: Time.current)
  end
  
  def incomplete!
    update!(status_task: false, completed_at: nil)
  end
  
  def completed?
    status_task
  end
  
  def active?
    !status_task
  end
  
  def duration_days
    return 0 unless start_date && end_date
    ((end_date - start_date) / 1.day).to_i + 1
  end
  
  def progress_percentage
    return 0 unless start_date && end_date
    today = Date.current
    return 0 if today < start_date.to_date
    return 100 if today > end_date.to_date || completed?
    
    total_days = duration_days
    elapsed_days = (today - start_date.to_date).to_i + 1
    (elapsed_days.to_f / total_days * 100).round(1)
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, 'は開始日以降の日付を選択してください') if end_date < start_date
  end
end
