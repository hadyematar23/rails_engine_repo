class Api::V1::Merchants::FindController < ApplicationController

  def show
    merchant = Merchant.find_individual_merchant(params[:name])

    if merchant 
      render json: MerchantFindSerializer.new(merchant)
    else
      render json: NoMatchSerializer.no_match
    end 
  end

  def index 
    render json: MerchantFindSerializer.new(Merchant.find_all_merchants(params[:name]))
  end

end
