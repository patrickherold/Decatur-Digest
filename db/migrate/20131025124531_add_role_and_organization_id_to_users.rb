class AddRoleAndOrganizationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string
    add_column :users, :organization_id, :integer
  end
end
