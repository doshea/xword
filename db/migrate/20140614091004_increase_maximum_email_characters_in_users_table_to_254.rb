class IncreaseMaximumEmailCharactersInUsersTableTo254 < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, limit: 254
  end
end
