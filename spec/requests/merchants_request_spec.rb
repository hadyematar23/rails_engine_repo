require 'rails_helper'

RSpec.describe "Merchants", type: :request do
  describe "GET /index" do
    it "gets all of the merchants" do 
      create_list(:merchant, 5)

      get "/api/v1/merchants"

      parsed_merchants = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:success)
      expect(parsed_merchants).to have_key(:data)
      expect(parsed_merchants[:data]).to be_a(Array)
      expect(parsed_merchants[:data].count).to eq(Merchant.all.count)

      parsed_merchants[:data].each do |merchant_data|
        expect(merchant_data).to have_key(:id)
        expect(merchant_data).to have_key(:type)
        expect(merchant_data).to have_key(:attributes)
        expect(merchant_data[:attributes]).to have_key(:name)
      end

    end

    it "can get one merchant" do 
      create_list(:merchant, 5)
      get "/api/v1/merchants/#{Merchant.first.id}"

      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(:success)
      expect(parsed_merchant).to have_key(:data)
      expect(parsed_merchant[:data]).to be_a(Hash)
      expect(parsed_merchant[:data][:id]).to eq(Merchant.first.id.to_s)
      expect(parsed_merchant[:data][:attributes][:name]).to eq(Merchant.first.name)
      expect(parsed_merchant[:data]).to have_key(:type)

    end

    it "sad path for getting one merchant" do 
      create_list(:merchant, 5)
      get "/api/v1/merchants/#{Merchant.last.id+1}"

      expect(response).to have_http_status(404)
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_merchant[:errors].first[:message]).to eq("Merchant not found")

    end 

    it "can get all items for a specific merchant id" do 
      create_list(:merchant, 5)

      create(:item, merchant: Merchant.first, name: "Turing")
      create(:item, merchant: Merchant.first, name: "Ring World")
      create(:item, merchant: Merchant.first, name: "Neither")
      create_list(:item, 5, merchant: Merchant.all.last)

      get "/api/v1/merchants/#{Merchant.first.id}/items"
      parsed_items = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:success)
      expect(parsed_items).to have_key(:data)
      expect(parsed_items[:data]).to be_a(Array)
      expect(parsed_items[:data].count).to eq(3)
      
      names = parsed_items[:data].map do |item|
        item[:attributes][:name]
      end

      expect(names).to match_array(["Neither", "Ring World", "Turing"])

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
      expect(response).to have_http_status(404)
      expect(parsed_items[:errors].first[:message]).to eq("Merchant not found")
    end
  end
end
