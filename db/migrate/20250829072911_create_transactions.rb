class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :transaction_type
      t.decimal :amount, precision: 15, scale: 2
      t.string :currency
      t.bigint "source_wallet_id"
      t.bigint "target_wallet_id"
      t.text :description

      t.timestamps
    end

    add_foreign_key "transactions", "wallets", column: "source_wallet_id"
    add_foreign_key "transactions", "wallets", column: "target_wallet_id"
    add_index :transactions, :source_wallet_id
    add_index :transactions, :target_wallet_id
  end
end
