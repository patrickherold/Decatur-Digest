class LotStateMachine < ActiveRecord::Migration
  def change
    add_column :lots, :state, :string 
    add_column :lots, :timestamps, :datetime 
  end
end


