class AddTeamAndKeyToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :team, :boolean, default: false, null: false
    add_column :solutions, :key, :string
  end
end
