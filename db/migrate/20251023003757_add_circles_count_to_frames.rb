class AddCirclesCountToFrames < ActiveRecord::Migration[8.0]
  def change
    add_column :frames, :circles_count, :integer, default: 0, null: false
  end
end
