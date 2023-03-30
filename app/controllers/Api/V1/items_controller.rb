module Api
  module V1
    class ItemsController < ApplicationController

      def index 
        if params[:merchant_id]
          begin
            render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
          rescue ActiveRecord::RecordNotFound
            render json: ErrorSerializer.new("Merchant not found").serialize_json, status: :not_found
          end
        else 
          render json: ItemSerializer.new(Item.all)
        end 
      end

      def show
        begin 
          render json: ItemSerializer.new(Item.find(params[:id]))
        rescue ActiveRecord::RecordNotFound
          render json: ErrorSerializer.new("Item not found").serialize_json, status: :not_found
        end
      end

      def create
        item = Item.new(new_item_params)
        if item.save
          render json: ItemSerializer.new(Item.all.last), status: 201
        else  
          render json: ErrorSerializer.new(item.errors.full_messages.first).serialize_json, status: 422
        end
      end

      def destroy 
        begin 
          item = Item.find(params[:id])
          invoice = item.find_invoices_to_destroy 
          invoice.each { |invoice| invoice.destroy }
          item.destroy
        rescue ActiveRecord::RecordNotFound
          render json: ErrorSerializer.new("Item not found and therefore could not be deleted").serialize_json, status: :not_found
        end
      end

      def update
        begin
          item = Item.find(params[:id])
          if item.update(new_item_params)
            render json: ItemSerializer.new(Item.find(params[:id]))
          else  
            render json: {
              error: item.errors.full_messages, 
            }, status: 404
          end 
        rescue ActiveRecord::RecordNotFound
          render json: ErrorSerializer.new("Item not found and therefore could not be updated").serialize_json, status: :not_found
        end 
      end

      private 

      def new_item_params
        params.permit(:name, :description, :unit_price, :merchant_id,)
      end

    end
  end
end 
