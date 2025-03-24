# == Schema Information
#
# Table name: color_themes
#
#  id              :integer          not null, primary key
#  accent_color    :string
#  neutral_color   :string
#  primary_color   :string
#  secondary_color :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer          not null
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
