class CreateColorThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :color_themes do |t|
      t.references :school, null: false, foreign_key: true
      t.string :primary_color
      t.string :secondary_color
      t.string :tertiary_color
      t.string :accent_color

      t.timestamps
    end
  end
end
