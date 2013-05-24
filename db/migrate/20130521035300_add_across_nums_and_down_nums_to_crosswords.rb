class AddAcrossNumsAndDownNumsToCrosswords < ActiveRecord::Migration
  def change
    add_column :crosswords, :across_nums, :text, default: '', null: false
    add_column :crosswords, :down_nums, :text, default: '', null: false
  end
end
