class ErrorSerializer
  include JSONAPI::Serializer
  attributes 

  def self.price
    {errors: "Price Cannot be Less than 0 (Zero)"}
  end

  def self.too_much_params
    {errors: "Cannot search by price and name"}
  end
end
