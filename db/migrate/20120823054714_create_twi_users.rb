class CreateTwiUsers < ActiveRecord::Migration
  def change
    create_table :twi_users do |t|
      t.integer :uid
      t.string :handler
      t.string :access_token

      t.timestamps
    end
  end
end
