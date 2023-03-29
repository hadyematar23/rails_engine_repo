class Api::V1::MerchantsController < ApplicationController
  def index 
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if params[:item_id]
      render json: MerchantSerializer.new(Item.find(params[:item_id]).merchant)
    else 
      begin 
        render json: MerchantSerializer.new(Merchant.find(params[:id]))
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Merchant not found" }, status: :not_found
      end
    end 
  end 
end 




