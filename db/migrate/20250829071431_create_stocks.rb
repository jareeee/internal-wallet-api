class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
