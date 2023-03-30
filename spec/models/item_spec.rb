require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "instance methods" do 
    it "will destroy the invoice if the item to be destroyed is the only item on the invoice" do 
      create_list(:merchant, 1)
      create_list(:item, 3, merchant: Merchant.first)
      create_list(:invoice, 3, merchant: Merchant.first)
      create_list(:invoice_item, 1, item: Item.first, invoice: Invoice.first)
      create_list(:invoice_item, 1, item: Item.second, invoice: Invoice.first)
      create_list(:invoice_item, 1, item: Item.second, invoice: Invoice.second)
      create_list(:invoice_item, 1, item: Item.third, invoice: Invoice.third)

      deleted_item = Item.second

      expect(Item.second.find_invoices_to_destroy).to eq([Invoice.second])

    end
  end 

  describe "class methods" do 

    it "searches the database by name and returns the first (by alphabetized) item name from the search list" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")

      query = "ring"

      result = Item.return_first_alphabetized(query).name

      expect(result).to eq("Ring World")
    end

    it "searches the database by name and returns all items in the search list" do 
      create(:item, name: "Turing")
      create(:item, name: "Ring World")
      create(:item, name: "Neither")

      query = "ring"
      
      result = Item.return_all_items(query)

      expect(result).to match_array([Item.first, Item.second])
    end

    it "searches for and returns all items where the minimum price is equal to or greater than the query" do 
      create(:item, unit_price: 3.54)
      create(:item, unit_price: 11.23, name: "shoes")
      create(:item, unit_price: 12.00, name: "wallet")
      create(:item, unit_price: 18.23, name: "trousers")

      query = 11.23

      results = Item.return_with_min_price(query)
      
      expect(results).to match_array([Item.second, Item.third, Item.fourth])

    end

    it "searches for and returns all items where the maximum price is equal to or less than the query" do 
      create(:item, unit_price: 3.54)
      create(:item, unit_price: 11.23, name: "shoes")
      create(:item, unit_price: 12.00, name: "wallet")
      create(:item, unit_price: 18.23, name: "trousers")

      query = 12.00

      results = Item.return_with_max_price(query)
      
      expect(results).to match_array([Item.first, Item.second, Item.third])

    end

    it "searches for and returns all items where the items' prices are between the max price and the min price" do 
      create(:item, unit_price: 3.54)
      create(:item, unit_price: 11.23, name: "shoes")
      create(:item, unit_price: 12.00, name: "wallet")
      create(:item, unit_price: 18.23, name: "trousers")

      min_price = 11.00
      max_price = 12.00

      results = Item.return_between_both_prices(min_price, max_price)
      
      expect(results).to match_array([Item.second, Item.third])

    end
  end
end

