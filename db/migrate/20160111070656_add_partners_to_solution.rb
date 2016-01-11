class AddPartnersToSolution < ActiveRecord::Migration
  def change
    add_column :solutions, :partner_ids, :text, array: true, default: []
  end
end
