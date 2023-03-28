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
      expect(parsed_merchants[:data].count).to eq(5)

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
      expect(parsed_merchant).to have_key(:error)
      expect(parsed_merchant[:error]).to eq("Merchant not found")

    end 


  end
end
