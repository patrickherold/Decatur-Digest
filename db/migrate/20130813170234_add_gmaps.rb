class AddGmaps < ActiveRecord::Migration
  def up
    add_column :lots, :gmaps, :boolean
  end

  def down
  end
end
