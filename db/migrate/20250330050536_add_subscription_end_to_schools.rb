class AddSubscriptionEndToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :subscription_end, :datetime
  end
end
