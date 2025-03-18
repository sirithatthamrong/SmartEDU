FactoryBot.define do
  factory :school do
    name { Faker::University.name }
    sequence(:id) { |n| n }
    has_paid { 1 }
    address { Faker::Address.full_address }
  end
end
