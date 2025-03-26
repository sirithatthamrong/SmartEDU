class CreateColorThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :color_themes do |t|
      t.references :school, null: false, foreign_key: true
      t.string :primary_color
      t.string :secondary_color
      t.string :accent_color
      t.string :base_100_color
      t.string :base_200_color
      t.string :base_300_color
      t.string :base_500_color
      t.string :base_content_color
      t.string :neutral_color
      t.string :neutral_content_color
      t.timestamps
    end
  end
end
