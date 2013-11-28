class CreateSolutionPartnerings < ActiveRecord::Migration
  def change
    create_table :solution_partnerings do |t|
      t.belongs_to :user
      t.belongs_to :solution
      t.timestamps
    end
  end
end