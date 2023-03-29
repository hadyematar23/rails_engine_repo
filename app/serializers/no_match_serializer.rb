class NoMatchSerializer
  include JSONAPI::Serializer

  def self.no_match
    {data: {}}
  end

end
