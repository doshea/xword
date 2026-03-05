class AddAccountSettingsColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notification_preferences, :jsonb, default: {}, null: false
    add_column :users, :deleted_at, :datetime, null: true
  end
end
