FactoryBot.define do 
  factory :merchant do 
    name {Faker::Company.name}
    created_at { Faker::Time.between(from: 30.days.ago, to: Time.now) }
    updated_at { created_at }
  end
end