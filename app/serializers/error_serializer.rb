class ErrorSerializer
  include JSONAPI::Serializer
  
  def initialize(error_message)
    @error_message = error_message
  end

  def serialize_json
    {
      data: {
        id: nil, 
        type: "error_message", 
        errors: @error_message, 
        attributes: {}
      }
    }
  end
end
