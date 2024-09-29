class CreateDefaultCollates < ActiveRecord::Migration[8.0]
  def change
    create_table :default_collates do |t|
      t.string :name

      t.timestamps
    end
  end
end
