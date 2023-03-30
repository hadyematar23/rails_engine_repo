require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "GET /index" do
    it "can get all the items" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)

      get "/api/v1/items"
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(200)
      expect(parsed_items).to have_key(:data)
      expect(parsed_items[:data]).to be_a(Array)
      expect(parsed_items[:data].count).to eq(Item.all.count)
      
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

    it "can get one item" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)

      get "/api/v1/items/#{Item.all.first.id}"
        parsed_items = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(200)
        expect(parsed_items).to have_key(:data)
        expect(parsed_items[:data]).to be_a(Hash)
        expect(parsed_items[:data]).to have_key(:id)
        expect(parsed_items[:data][:id]).to eq(Item.all.first.id.to_s)
        expect(parsed_items[:data]).to have_key(:type)
        expect(parsed_items[:data]).to have_key(:attributes)
        expect(parsed_items[:data][:type]).to be_a(String)
        expect(parsed_items[:data][:type]).to eq("item")
        expect(parsed_items[:data][:attributes]).to be_a(Hash)
        expect(parsed_items[:data][:attributes]).to have_key(:name)
        expect(parsed_items[:data][:attributes]).to have_key(:description)
        expect(parsed_items[:data][:attributes]).to have_key(:unit_price)
        expect(parsed_items[:data][:attributes]).to have_key(:merchant_id)
        expect(parsed_items[:data][:attributes][:name]).to be_a(String)
        expect(parsed_items[:data][:attributes][:name]).to be_a(String)
        expect(parsed_items[:data][:attributes][:description]).to be_a(String)
        expect(parsed_items[:data][:attributes][:unit_price]).to be_a(Float)
        expect(parsed_items[:data][:attributes][:merchant_id]).to eq(Item.all.first.merchant_id)
    end

    it "sad path- bad integer id - can get one item" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)

      get "/api/v1/items/#{Item.all.last.id+1}"
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(404)
      expect(parsed_items[:errors].first[:message]).to eq("Item not found")
      
    end

    it "edge case- insert string - can get one item" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)

      get "/api/v1/items/test"
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(404)
      expect(parsed_items[:errors].first[:message]).to eq("Item not found")
      
    end

    it "create item" do 
      create_list(:merchant, 1)
      create_list(:item, 3, merchant: Merchant.all.first)
      item_params = {
        name: "Wallet", 
        description: "Holds money", 
        unit_price: 3.45,
        merchant_id: Merchant.all.first.id
      }

      expect(Item.all.count).to eq(3)

      post "/api/v1/items", params: item_params
      expect(response).to have_http_status(201)
      expect(Item.all.count).to eq(4)
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_items[:data]).to be_a(Hash)
      expect(parsed_items[:data]).to have_key(:id)
      expect(parsed_items[:data]).to have_key(:type)
      expect(parsed_items[:data]).to have_key(:attributes)

      expect(parsed_items[:data][:attributes]).to have_key(:name)
      expect(parsed_items[:data][:attributes][:name]).to be_a(String)
      expect(parsed_items[:data][:attributes]).to have_key(:description)
      expect(parsed_items[:data][:attributes][:description]).to be_a(String)
      expect(parsed_items[:data][:attributes]).to have_key(:unit_price)
      expect(parsed_items[:data][:attributes][:unit_price]).to be_a(Float)
      expect(parsed_items[:data][:attributes]).to have_key(:merchant_id)
      expect(parsed_items[:data][:attributes][:merchant_id]).to be_a(Integer)
      
    end

    it "sad path- create item- attribute types not correct as unit price is a string and not a float" do 
      create_list(:merchant, 1)
      create_list(:item, 1, merchant: Merchant.all.first)
      item_params = {
        name: "Wallet", 
        description: "holds money", 
        unit_price: "string",
        merchant_id: Merchant.all.first.id
      }

      expect(Item.all.count).to eq(1)

      post "/api/v1/items", params: item_params
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(422)
      expect(Item.all.count).to eq(1)
      expect(response_body[:errors].first[:message]).to eq("Unit price is not valid. Make sure it is a number with a decimal point") 
    end

    it "sad path- create item- attribute types not correct as name is integer and not a string" do 
      create_list(:merchant, 1)
      create_list(:item, 1, merchant: Merchant.all.first)
      item_params = {
        name: 34, 
        description: "holds money", 
        unit_price: 23.5,
        merchant_id: Merchant.all.first.id
      }

      expect(Item.all.count).to eq(1)

      post "/api/v1/items", params: item_params

      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(422)
      expect(Item.all.count).to eq(1)
      expect(response_body[:errors].first[:message]).to eq("Name is not valid") 
    end

    it "sad path- create item- attribute types not correct as name is integer and not a string" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)
      item_params = {
        name: "task manager", 
        description: 25, 
        unit_price: 23.5,
        merchant_id: Merchant.all.first.id
      }

      expect(Item.all.count).to eq(12)

      post "/api/v1/items", params: item_params
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(422)
      expect(Item.all.count).to eq(12)
      expect(response_body[:errors].first[:message]).to eq("Description is not valid")
    end

    it "edge case- create item- attributes are missing (nil)" do 
      create_list(:merchant, 1)
      create_list(:item, 12, merchant: Merchant.all.first)
      item_params = {
        name: nil, 
        description: nil, 
        unit_price: nil,
        merchant_id: Merchant.all.first.id
      }

      expect(Item.all.count).to eq(12)

      post "/api/v1/items", params: item_params
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(422)
      expect(Item.all.count).to eq(12)
      expect(response_body[:errors].first[:message]).to eq("Name can't be blank")
    end

    it "delete item" do 
      create_list(:merchant, 1)
      create_list(:item, 3, merchant: Merchant.all.first)

      expect(Item.all.count).to eq(3)

      delete "/api/v1/items/#{Item.all.last.id}"

      expect(Item.all.count).to eq(2)
      expect(response.status).to eq(204)
    end 

    it "deleting the item also deletes the invoice if this is the only item on the invoice" do 
      create_list(:merchant, 1)
      create_list(:item, 3, merchant: Merchant.first)
      create_list(:invoice, 3, merchant: Merchant.first)
      create_list(:invoice_item, 1, item: Item.first, invoice: Invoice.first)
      create_list(:invoice_item, 1, item: Item.second, invoice: Invoice.first)
      create_list(:invoice_item, 1, item: Item.second, invoice: Invoice.second)
      create_list(:invoice_item, 1, item: Item.third, invoice: Invoice.third)

      
      surviving_invoice_1 = Invoice.first
      surviving_invoice_3 = Invoice.third

      delete "/api/v1/items/#{Item.second.id}"
      expect(Invoice.all.count).to eq(2)
      expect(Invoice.pluck(:id)).to include(surviving_invoice_1.id, surviving_invoice_3.id)

    end

    it "sad path - delete item" do 
      create_list(:merchant, 1)
      create_list(:item, 3, merchant: Merchant.all.first)

      expect(Item.all.count).to eq(3)

      delete "/api/v1/items/#{Item.all.last.id+1}"

      expect(Item.all.count).to eq(3)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:errors].first[:message]).to eq("Item not found and therefore could not be deleted")
      expect(response.status).to eq(404)
    end 

    it "update one item, one attribute" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 1, merchant: Merchant.all.second, name: "Keys", description: "hold things", unit_price: 3.43)

      item_params = {
        name: "Chain"
      }

      item_to_update = Item.all.find_by(description: "hold things")

      expect(item_to_update.name).to eq("Keys")
      
      patch "/api/v1/items/#{item_to_update.id}", params: item_params

      expect(item_to_update.name).to eq("Keys")


      expect(response).to have_http_status(200)
      expect(Item.all.count).to eq(4)
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      
      expect(parsed_items[:data]).to be_a(Hash)
      expect(parsed_items[:data]).to have_key(:id)
      expect(parsed_items[:data]).to have_key(:type)
      expect(parsed_items[:data]).to have_key(:attributes)

      expect(parsed_items[:data][:attributes][:name]).to eq("Chain")
      expect(parsed_items[:data][:attributes][:description]).to eq("hold things")
      expect(parsed_items[:data][:attributes][:unit_price]).to eq(3.43)

    end

    it "update one item, all attribute" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 1, merchant: Merchant.all.second, name: "Keys", description: "hold things", unit_price: 3.43)

      item_params = {
        name: "Chain", 
        description: "best thing", 
        unit_price: 45.6, 
        merchant_id: Merchant.all.first.id
      }

      item_to_update = Item.all.find_by(description: "hold things")

      expect(item_to_update.name).to eq("Keys")
      expect(item_to_update.description).to eq("hold things")
      expect(item_to_update.unit_price).to eq(3.43)

      put "/api/v1/items/#{item_to_update.id}", params: item_params

      expect(response).to have_http_status(200)
      expect(Item.all.count).to eq(4)
      parsed_items = JSON.parse(response.body, symbolize_names: true)
      
      expect(parsed_items[:data]).to be_a(Hash)
      expect(parsed_items[:data]).to have_key(:id)
      expect(parsed_items[:data]).to have_key(:type)
      expect(parsed_items[:data]).to have_key(:attributes)

      expect(parsed_items[:data][:attributes][:name]).to eq("Chain")
      expect(parsed_items[:data][:attributes][:description]).to eq("best thing")
      expect(parsed_items[:data][:attributes][:unit_price]).to eq(45.6)

    end

    it "sad path- bad integer id" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 1, merchant: Merchant.all.second, name: "Keys", description: "hold things", unit_price: 3.43)

      item_params = {
        name: "Chain"
      }

      item_to_update = Item.all.find_by(description: "hold things")

      patch "/api/v1/items/#{item_to_update.id+20}", params: item_params

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:errors].first[:message]).to eq("Item not found and therefore could not be updated")

      expect(response.status).to eq(404)
    end 

    it "edge case- bad string integer id returns 404" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 1, merchant: Merchant.all.second, name: "Keys", description: "hold things", unit_price: 3.43)

      item_params = {
        name: "Chain"
      }

      item_to_update = Item.all.find_by(description: "hold things")

      patch "/api/v1/items/#{item_to_update.id+20}", params: item_params

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:errors].first[:message]).to eq("Item not found and therefore could not be updated")

      expect(response.status).to eq(404)
    end 

    it "edge case- bad merchant integer id returns 404" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 1, merchant: Merchant.all.second, name: "Keys", description: "hold things", unit_price: 3.43)

      item_params = {
        merchant_id: 99999999999999
      }
      
      item_to_update = Item.all.find_by(description: "hold things")
      
      patch "/api/v1/items/#{item_to_update.id}", params: item_params
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      
      expect(response_body[:error].first).to eq("Merchant must exist")
      
      expect(response.status).to eq(404)
    end 

    it "get merchant data for given item ID" do 
      create_list(:merchant, 2)
      create_list(:item, 3, merchant: Merchant.all.first)
      create_list(:item, 3, merchant: Merchant.all.last)


      get "/api/v1/items/#{Item.all.first.id}/merchant"

      parsed_merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(200)
      expect(parsed_merchant).to have_key(:data)
      expect(parsed_merchant[:data]).to be_a(Hash)
      expect(parsed_merchant[:data][:id]).to eq(Merchant.first.id.to_s)
      expect(parsed_merchant[:data][:attributes][:name]).to eq(Merchant.first.name)
      expect(parsed_merchant[:data]).to have_key(:type)
    end
  end
end
