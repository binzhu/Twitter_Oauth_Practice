class AddTokenSecretToTwiUser < ActiveRecord::Migration
  def change
    add_column :twi_users, :token_secret, :string
  end
end
