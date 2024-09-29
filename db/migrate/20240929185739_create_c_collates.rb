class CreateCCollates < ActiveRecord::Migration[8.0]
  def change
    create_table :c_collates do |t|
      t.string :name

      t.timestamps
    end
  end
end
