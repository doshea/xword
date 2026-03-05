class AddRebusMapToCrosswordsAndSolutions < ActiveRecord::Migration[8.1]
  def change
    add_column :crosswords, :rebus_map, :jsonb, default: {}, null: false
    add_column :solutions,  :rebus_map, :jsonb, default: {}, null: false
  end
end
