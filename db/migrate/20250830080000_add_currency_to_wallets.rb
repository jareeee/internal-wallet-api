class AddCurrencyToWallets < ActiveRecord::Migration[8.0]
  def change
    add_column :wallets, :currency, :string, null: false, default: "IDR"
    change_column_default :wallets, :currency, nil
    add_index :wallets, [ :walletable_id, :walletable_type, :currency ], unique: true, name: "index_wallets_on_walletable_and_currency"
  end
end
