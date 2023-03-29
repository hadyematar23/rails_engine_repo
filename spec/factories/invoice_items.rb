FactoryBot.define do
  factory :invoice_item do
    unit_price { Faker::Commerce.price(range: 0.01..100.00, as_string: false) }
    quantity { Faker::Number.between(from: 1, to: 100) }
    association :item 
    association :invoice
    created_at { Faker::Time.between(from: 30.days.ago, to: Time.now) }
    updated_at { created_at }
    
  end
end
