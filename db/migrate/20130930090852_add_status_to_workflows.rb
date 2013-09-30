class AddStatusToWorkflows < ActiveRecord::Migration
  def change
    add_column :workflows, :status, :text
  end
end
