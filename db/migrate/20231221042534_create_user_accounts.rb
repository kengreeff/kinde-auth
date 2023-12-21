class CreateUserAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_accounts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :provider
      t.string :provider_account_id

      t.timestamps
    end
  end
end