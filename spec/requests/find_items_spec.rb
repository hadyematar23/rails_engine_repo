require 'rails_helper'

RSpec.describe "Finds_items", type: :request do
  describe "GET /index" do
    it "is able to search for a single item that matches a search term" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")
      
      get "/api/v1/items/find?name=ring"
      parsed_items = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_items[:data]).to be_a(Hash)
      expect(parsed_items[:data]).to have_key(:id)
      expect(parsed_items[:data]).to have_key(:type)
      expect(parsed_items[:data]).to have_key(:attributes)
      expect(parsed_items[:data][:attributes]).to have_key(:name)
      expect(parsed_items[:data][:attributes]).to have_key(:description)
      expect(parsed_items[:data][:attributes]).to have_key(:unit_price)
      expect(parsed_items[:data][:attributes]).to have_key(:merchant_id)
      expect(parsed_items[:data][:attributes][:name]).to eq("Ring World")

      expect(response.status).to be(200)
    end

    it "sad path- if it searches for a single item and there is no item, then it will return a 200 status code but indicate that there is no match" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")

      get "/api/v1/items/find?name=NOMATCH"
      parsed_item = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(200)
      expect(parsed_item).to be_a(Hash)
      expect(parsed_item).to have_key(:data)
      expect(parsed_item[:data]).to be_empty
    end

    it "edgecase- searches for all items that match the search term and if none exists, it will return 200 and a blank array" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")

      get "/api/v1/merchants/find_all?name=NOMATCH"
      parsed_item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(200)
      expect(parsed_item).to be_a(Hash)
      expect(parsed_item[:data]).to be_a(Array)
      expect(parsed_item).to have_key(:data)

      expect(parsed_item[:data]).to be_empty

    end

    it "is able to search for all items that match a search term" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")
      
      get "/api/v1/items/find_all?name=ring"
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_items[:data]).to be_a(Array)
      expect(parsed_items[:data].count).to eq(2)

      names = parsed_items[:data].map do |item| 
        item[:attributes][:name] 
      end 
      
      expect(names).to match_array(["Turing", "Ring World"])

      parsed_items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item).to have_key(:id)
        expect(item).to have_key(:type)
        expect(item).to have_key(:attributes)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:unit_price]).to be_a(Float)
      end
      
      expect(response.status).to be(200)
    end

    describe "prices" do 
      it "can search for and return ALL ITEMS everything with a minimum price equal or greater to input (so everything equal to or greater than the parameter)" do 
        create(:item, unit_price: 3.54)
        create(:item, unit_price: 11.23, name: "shoes")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        
        get "/api/v1/items/find_all?min_price=11.23"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(200)
        expect(parsed_items[:data]).to be_a(Array)
        expect(parsed_items[:data].count).to eq(3)
      
        names = parsed_items[:data].map do |item|
          item[:attributes][:name]
        end

        expect(names).to match_array(["wallet", "trousers", "shoes"])
      end

      it "can search for and return ALL ITEMS everything with a maximum price equal or greater to input (so anything equal to or less than the input)" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?max_price=18.23"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(200)
        expect(parsed_items[:data]).to be_a(Array)
        expect(parsed_items[:data].count).to eq(3)
      
        names = parsed_items[:data].map do |item|
          item[:attributes][:name]
        end

        expect(names).to match_array(["wallet", "trousers", "computer"])
      end

      it "can search for and return ALL ITEMS within the maximum and minimum prices" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?max_price=18.23&min_price=8.32"

        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(200)
        expect(parsed_items[:data]).to be_a(Array)
        expect(parsed_items[:data].count).to eq(2)
      
        names = parsed_items[:data].map do |item|
          item[:attributes][:name]
        end

        expect(names).to match_array(["wallet", "trousers"])
      end

      it "if you input a max price less than 0 it will return an error" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?max_price=-15"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(400)
        expect(parsed_items[:errors].first[:message]).to eq("Price Cannot be Less than 0 (Zero)")

      end

      it "if you input a min price less than 0 it will return an error" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?min_price=-15"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(400)
        expect(parsed_items[:errors].first[:message]).to eq("Price Cannot be Less than 0 (Zero)")

      end

      it "if you input a min price and a name it will return an error" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?min_price=5&name=tacos"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(400)
        expect(parsed_items[:errors].first[:message]).to eq("Cannot search by price and name")

      end

      it "if you input a min price and a name it will return an error" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all?max_price=5&name=tacos"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(400)
        expect(parsed_items[:errors].first[:message]).to eq("Cannot search by price and name")

      end

      it "if you are seeking to find all items but input no param, you get an error" do 
        create(:item, unit_price: 3.54, name: "computer")
        create(:item, unit_price: 12.00, name: "wallet")
        create(:item, unit_price: 18.23, name: "trousers")
        create(:item, unit_price: 20.45, name: "desk")

        get "/api/v1/items/find_all"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to be(400)
        expect(parsed_items[:errors].first[:message]).to eq("You did not input any items to search for")

      end
    end
  end
end
