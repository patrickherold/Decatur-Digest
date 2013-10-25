class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :address
      t.string :parent_organization_id

      t.timestamps
    end
    add_attachment :organizations, :image
  end
end
