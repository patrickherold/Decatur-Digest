class AddWorkflowManagersUsers < ActiveRecord::Migration
  def up
    create_table :workflow_managers_users, :id => false do |t|
      t.integer :user_id
      t.integer :manager_id
    end
  end

  def down
    drop_table :workflow_managers_users
  end
end
