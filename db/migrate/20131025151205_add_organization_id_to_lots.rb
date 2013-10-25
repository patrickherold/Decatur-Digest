class AddOrganizationIdToLots < ActiveRecord::Migration
  def change
    add_column :lots, :organization_id, :integer
  end
end
