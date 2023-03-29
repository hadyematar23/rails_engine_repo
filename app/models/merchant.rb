class Merchant < ApplicationRecord
  has_many :items

  def self.find_individual_merchant(query)
    Merchant.where("name ILIKE?", "%#{query}%").order(:name).first
  end

  def self.find_all_merchants(query)
    Merchant.where("name ILIKE?", "%#{query}%")
  end
end
