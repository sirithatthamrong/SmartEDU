# frozen_string_literal: true

# == Schema Information
#
# Table name: schools
#
#  id               :integer          not null, primary key
#  address          :string           not null
#  has_paid         :boolean          default(FALSE)
#  name             :string           not null
#  subscription_end :datetime
#  tier             :integer          default(1)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_schools_on_name  (name) UNIQUE
#
class School < ApplicationRecord
  has_one :school_tier
  has_many :users
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true
  has_one :color_theme, dependent: :destroy
  accepts_nested_attributes_for :color_theme
  after_create :set_default_color_theme

  def subscription_active?
    subscription_end.present? && subscription_end > Time.zone.now
  end

  private
  def set_default_color_theme
    create_color_theme!(
      theme_name: "mytheme",
      primary_color: "#8294C4",
      primary_content_color: "#FFFFFF",
      secondary_color: "#ACB1D6",
      secondary_content_color: "#F3FAFF",
      accent_color: "#FFEAD2",
      accent_content_color: "#00182A",
      base_100_color: "#FFFFFF",
      base_200_color: "#F8F8F8",
      base_300_color: "#C6C6C6",
      base_500_color: "#d0d0d0",
      base_content_color: "#00182A",
      neutral_color: "#6B8A9E",
      neutral_content_color: "#F3FAFF"
    )
  end
end
