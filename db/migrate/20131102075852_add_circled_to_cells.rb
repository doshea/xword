class AddCircledToCells < ActiveRecord::Migration
  def change
    add_column :cells, :circled, :boolean, default: false
  end
end
