class RemoveGridnumsFromCrosswords < ActiveRecord::Migration
  def change
    remove_column :crosswords, :gridnums
  end
end
