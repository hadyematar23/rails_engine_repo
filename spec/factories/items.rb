FactoryBot.define do 
  factory :item do 
    name {Faker::Commerce.product_name}
    description { Faker::Lorem.sentence }
    unit_price { Faker::Commerce.price(range: 0.01..100.00, as_string: false) }
    association :merchant
    created_at { Faker::Time.between(from: 30.days.ago, to: Time.now) }
    updated_at { created_at }
  end
end