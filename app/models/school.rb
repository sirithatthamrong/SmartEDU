# frozen_string_literal: true

# == Schema Information
#
# Table name: schools
#
#  id               :integer          not null, primary key
#  address          :string           not null
#  has_paid         :boolean
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

  def subscription_active?
    subscription_end.present? && subscription_end > Time.zone.now
  end
end
