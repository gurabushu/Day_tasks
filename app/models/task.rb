class Task < ApplicationRecord
  # デフォルト値の設定
  after_initialize :set_defaults, if: :new_record?
  
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
  scope :for_month, ->(date) { 
    month_start = date.beginning_of_month.beginning_of_week
    month_end = date.end_of_month.end_of_week
    where('start_date <= ? AND end_date >= ?', month_end, month_start)
  }
  
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
    @duration_days ||= ((end_date - start_date) / 1.day).to_i + 1
  end
  
  def progress_percentage
    return 0 unless start_date && end_date
    return @progress_percentage if defined?(@progress_percentage)
    
    today = Date.current
    return @progress_percentage = 0 if today < start_date.to_date
    return @progress_percentage = 100 if today > end_date.to_date || completed?
    
    total_days = duration_days
    elapsed_days = (today - start_date.to_date).to_i + 1
    @progress_percentage = (elapsed_days.to_f / total_days * 100).round(1)
  end
  
  # 指定された日付がタスクの期間内かどうか
  def covers_date?(date)
    return false unless start_date && end_date
    date_only = date.to_date
    date_only >= start_date.to_date && date_only <= end_date.to_date
  end
  
  private
  
  def set_defaults
    self.status_task = false if status_task.nil?
  end
  
  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, 'は開始日以降の日付を選択してください') if end_date < start_date
  end
end
