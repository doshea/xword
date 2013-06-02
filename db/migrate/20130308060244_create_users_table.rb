class CreateUsersTable < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username, :null => false
      t.string :email, :null => false
      t.boolean :is_admin, :default => false
      t.string :password_digest
      t.text :image, default: nil
      t.string :location
      t.string :auth_token
      t.timestamps
    end
  end
end
