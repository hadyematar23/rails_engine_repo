module Api
  module V1
    class MerchantsController < ApplicationController

      def index 
        render json: MerchantSerializer.new(Merchant.all)
      end

      def show
        begin 
          render json: MerchantSerializer.new(Merchant.find(params[:id]))
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Merchant not found" }, status: :not_found
        end
      end 
    end 
  end
end 



