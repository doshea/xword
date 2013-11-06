class AddCircledToCrosswords < ActiveRecord::Migration
  def change
    add_column :crosswords, :circled, :boolean, default: false
  end
end
