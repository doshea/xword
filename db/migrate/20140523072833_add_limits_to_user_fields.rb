class AddLimitsToUserFields < ActiveRecord::Migration
  def change
    change_column :users, :username, :string, limit: 16
    change_column :users, :email, :string, limit: 40
    change_column :users, :first_name, :string, limit: 18
    change_column :users, :last_name, :string, limit: 24
  end
end