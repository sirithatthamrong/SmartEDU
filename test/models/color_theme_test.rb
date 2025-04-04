# == Schema Information
#
# Table name: color_themes
#
#  id                      :integer          not null, primary key
#  accent_color            :string
#  accent_content_color    :string
#  base_100_color          :string
#  base_200_color          :string
#  base_300_color          :string
#  base_500_color          :string
#  base_content_color      :string
#  neutral_color           :string
#  neutral_content_color   :string
#  primary_color           :string
#  primary_content_color   :string
#  secondary_color         :string
#  secondary_content_color :string
#  theme_name              :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  school_id               :integer          not null
#
# Indexes
#
#  index_color_themes_on_school_id  (school_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
require "test_helper"

class ColorThemeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
