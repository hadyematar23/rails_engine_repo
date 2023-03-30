class Api::V1::Merchants::FindController < ApplicationController

  def show
    merchant = Merchant.find_individual_merchant(params[:name])
    if params[:name].nil? 
      render json: ErrorSerializer.new("You need to actually search for a merchant").serialize_json, status: 400
    elsif params[:name] ==""
      render json: ErrorSerializer.new("Please input a valid search.").serialize_json, status: 400
    elsif merchant 
      render json: MerchantSerializer.new(merchant)
    else
      render json: NoMatchSerializer.no_match
    end 
  end

  def index 
    render json: MerchantSerializer.new(Merchant.find_all_merchants(params[:name]))
  end

end
