require 'rails_helper'

RSpec.describe "Find_merchants", type: :request do
  describe "GET /index" do

    it "is able to search for a single merchant that matches a search term" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")
      
      get "/api/v1/merchants/find?name=hady"
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(200)
      expect(parsed_merchant).to have_key(:data)
      expect(parsed_merchant[:data]).to be_a(Hash)
      expect(parsed_merchant[:data]).to have_key(:id)
      expect(parsed_merchant[:data]).to have_key(:type)
      expect(parsed_merchant[:data]).to have_key(:attributes)
      expect(parsed_merchant[:data][:attributes][:name]).to eq("Hady")
    end 

    it "sad path- searches for a single merchant that matches the search term and if none exists, it will return 200 but indicate that there is no data" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")

      get "/api/v1/merchants/find?name=NOMATCH"
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(200)
      expect(parsed_merchant).to be_a(Hash)
      expect(parsed_merchant).to have_key(:data)
      expect(parsed_merchant[:data]).to be_empty

    end



    it "is able to search and return all merchants" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")
      
      get "/api/v1/merchants/find_all?name=hady"
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(200)
      expect(parsed_merchant).to have_key(:data)
      expect(parsed_merchant[:data]).to be_a(Array)

      parsed_merchant[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant).to have_key(:type)
        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to have_key(:name)
      end 

      names = parsed_merchant[:data].map do |item| 
        item[:attributes][:name] 
      end 
      
      expect(names).to match_array(["Pahady", "Hady"])
    end 

    it "edgecase- searches for all merchants that match the search term and if none exists, it will return 200 and a blank array" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")

      get "/api/v1/merchants/find_all?name=NOMATCH"
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(200)
      expect(parsed_merchant).to be_a(Hash)
      expect(parsed_merchant[:data]).to be_a(Array)
      expect(parsed_merchant).to have_key(:data)

      expect(parsed_merchant[:data]).to be_empty
    end

    it "edgecase - no parameter given will return error" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")

      get "/api/v1/merchants/find"
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(400)
      expect(parsed_merchant).to be_a(Hash)
      expect(parsed_merchant[:data][:errors]).to eq("You need to actually search for a merchant")
    end

    it "edgecase - parameter provided is empty" do 
      create(:merchant, name: "Pahady")
      create(:merchant, name: "Hady")
      create(:merchant, name: "Malena")

      get "/api/v1/merchants/find?name="
      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(400)
      expect(parsed_merchant).to be_a(Hash)
      expect(parsed_merchant[:data][:errors]).to eq("Please input a valid search.")
    end
  end 
end 
