module Api
  module V1
    class ItemsController < ApplicationController

      def index 
        begin
          render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Merchant not found" }, status: :not_found
        end
      end
    end
  end
end 
