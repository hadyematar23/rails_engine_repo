require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "GET /index" do
    it "can get all items for a specific merchant id" do 
      create_list(:merchant, 5)

      create_list(:item, 5, merchant: Merchant.all.first)
      create_list(:item, 5, merchant: Merchant.all.last)

      get "/api/v1/merchants/#{Merchant.first.id}/items"
      parsed_items = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:success)
      expect(parsed_items).to have_key(:data)
      expect(parsed_items[:data]).to be_a(Array)
      expect(parsed_items[:data].count).to eq(5)
      
      parsed_items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item).to have_key(:id)
        expect(item).to have_key(:type)
        expect(item).to have_key(:attributes)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(Merchant.first.id)
        expect(item[:attributes][:unit_price]).to be_a(Float)

      end
    end

    it "sad path- can get all items for a specific merchant id" do 
      create_list(:merchant, 5)

      create_list(:item, 5, merchant: Merchant.all.first)
      create_list(:item, 5, merchant: Merchant.all.last)

      get "/api/v1/merchants/#{Merchant.last.id+1}/items"
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      require 'pry'; binding.pry
      expect(response).to have_http_status(404)
      expect(parsed_items).to have_key(:error)
      expect(parsed_items[:error]).to eq("Merchant not found")
    end
  end
end
