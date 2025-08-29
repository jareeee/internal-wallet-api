class CreateBalanceSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :balance_snapshots do |t|
      t.references :wallet, null: false, foreign_key: true
      t.decimal :balance_amount, precision: 15, scale: 2
      t.date :snapshot_date

      t.timestamps
    end
  end
end
