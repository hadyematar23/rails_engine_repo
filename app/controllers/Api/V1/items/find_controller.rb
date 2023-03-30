class Api::V1::Items::FindController < ApplicationController

  def show 
    item = Item.return_first_alphabetized(params[:name])
    if under_zero(params)
      render json: ErrorSerializer.new("Price Cannot be Less than 0 (Zero)").serialize_json, status: 400
    elsif both_params(params)
      render json: ErrorSerializer.new("Cannot search by price and name").serialize_json, status: 400
    elsif item 
      render json: ItemSerializer.new(item)
    else 
      render json: NoMatchSerializer.no_match
    end 
  end

  def index 
    if both_params(params)
      render json: ErrorSerializer.new("Cannot search by price and name").serialize_json, status: 400
    elsif params[:name]
      render json: ItemSerializer.new(Item.return_all_items(params[:name]))
    elsif under_zero(params)
      render json: ErrorSerializer.new("Price Cannot be Less than 0 (Zero)").serialize_json, status: 400
    elsif both_prices(params)
      render json: ItemSerializer.new(Item.return_between_both_prices(params[:min_price], params[:max_price]))
    elsif params[:min_price]
      render json: ItemSerializer.new(Item.return_with_min_price(params[:min_price]))
    elsif params[:max_price]
      render json: ItemSerializer.new(Item.return_with_max_price(params[:max_price]))
    elsif params[:name].nil?
      render json: ErrorSerializer.new("You did not input any items to search for").serialize_json, status: 400
    end 
  end

  private 

  def under_zero(params)
    params[:max_price].to_f < 0 || params[:min_price].to_f < 0 
  end

  def both_params(params)
    params[:name] && (params[:min_price] || params[:max_price])
  end 

  def both_prices(params)
    params[:min_price] && params[:max_price]
  end

end
