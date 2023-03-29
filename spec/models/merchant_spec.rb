require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe "class methods" do 
    it "finds the individual merchant when a name query is provided" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hadythebest")
      create(:merchant, name: "Malena")

      query = "Hady"

      result = Merchant.find_individual_merchant(query).name

      expect(result).to eq("Hadythebest")
    end

    it "finds all merchants when a name query is provided" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Malena")
      create(:merchant, name: "Hadythebest")

      query = "Hady"

      result = Merchant.find_all_merchants(query)

      expect(result).to match_array([Merchant.first, Merchant.last])
    end
  end
end
