class AlterIncomeToMoney < ActiveRecord::Migration
  def up
    change_table :users do |t|
          t.money :income
        end
  end

  def down
  end
end
