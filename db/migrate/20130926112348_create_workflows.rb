class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :name
      t.text :description
      t.integer :user_id

      t.timestamps
    end
    create_table :lots_workflows, :id => false do |t|
      t.integer :lot_id
      t.integer :workflow_id
    end
    create_table :managers_workflows, :id => false do |t|
      t.integer :user_id
      t.integer :workflow_id
    end
  end
end
