# frozen_string_literal: true

# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  address    :string           not null
#  has_paid   :boolean          default(FALSE)
#  name       :string           not null
#  tier       :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_schools_on_name  (name) UNIQUE
#
class School < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true
  has_one :color_theme, dependent: :destroy
  accepts_nested_attributes_for :color_theme
  after_create :set_default_color_theme

  private

  def set_default_color_theme
    create_color_theme!(
      primary_color: "#8294C4",
      secondary_color: "#ACB1D6",
      accent_color: "#DBDFEA",
      neutral_color: "#FFEAD2"
    )
  end
end
