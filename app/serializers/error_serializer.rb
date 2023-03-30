class ErrorSerializer
  include JSONAPI::Serializer
  
  def initialize(error_message)
    @error_message = error_message
    # @status = status
  end

  def serialize_json
    {
      message: "Query cannot be completed", 
      errors: [ 
        {
        id: nil, 
        type: "error_message",
        status: nil, 
        message: @error_message, 
        attributes: {}
        }
      ]
    }
  end
end
