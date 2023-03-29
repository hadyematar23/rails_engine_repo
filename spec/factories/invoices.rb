FactoryBot.define do
  factory :invoice do
    association :merchant
    status { Faker::Lorem.word }
  end
end
