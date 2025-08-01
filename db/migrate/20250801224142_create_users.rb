class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :img
      t.boolean :objective
      t.boolean :complated_day_task
      t.boolean :create_day_task
      t.boolean :complated_objective

      t.timestamps
    end
  end
end
