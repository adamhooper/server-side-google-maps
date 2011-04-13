require 'httparty'

module ServerSideGoogleMaps
  class Server
    include HTTParty
    base_uri('http://maps.googleapis.com')

    def get(path, params)
      options = { :query => params }
      self.class.get("#{path}/json", options)
    end
  end
end
