class Api::V1::Items::FindController < ApplicationController

  def show 
    item = Item.return_first_alphabetized(params[:name])
    if item 
      render json: ItemFindSerializer.new(item)
    else 
      render json: NoMatchSerializer.no_match
    end 
  end

  def index 
    if params[:name] && (params[:min_price] || params[:max_price])
      render json: ErrorSerializer.too_much_params, status: 400
    elsif params[:name]
      render json: ItemFindSerializer.new(Item.return_all_items(params[:name]))
    elsif params[:max_price].to_f < 0 || params[:min_price].to_f < 0 
      render json: ErrorSerializer.price, status: 400
    elsif params[:min_price] && params[:max_price]
      render json: ItemFindSerializer.new(Item.all.where("unit_price >= ?", params[:min_price]).where("unit_price <= ?", params[:max_price]))
    elsif params[:min_price]
      render json: ItemFindSerializer.new(Item.all.where("unit_price >= ?", params[:min_price]))
    elsif params[:max_price]
      render json: ItemFindSerializer.new(Item.all.where("unit_price <= ?", params[:max_price]))
    end 

  end

end
