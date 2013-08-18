class HomesteadDetailsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :birthdate, :DATETIME
    add_column :users, :disabled_veteran, :boolean
    add_column :users, :income, :integer
  end

  def down
  end
end
