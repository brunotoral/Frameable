class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.decimal :center_y, precision: 12, scale: 4, null: false
      t.decimal :center_x, precision: 12, scale: 4, null: false
      t.decimal :radius, precision: 12, scale: 4, null: false
      t.references :frame, null: false, foreign_key: true

      t.timestamps
    end

    add_index :circles, %i[center_x center_y]
    add_index :circles, :radius
  end
end
