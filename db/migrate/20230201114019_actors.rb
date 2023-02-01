class Actors < ActiveRecord::Migration[7.0]
  def change
    create_table :actors do |t|
      t.string :name
      t.text :biography
      t.string :picture_url

      t.timestamps
    end
  end
end
