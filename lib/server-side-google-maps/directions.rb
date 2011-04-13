module ServerSideGoogleMaps
  class Directions
    def self.get(params)
      server = Server.new
      server.get('/maps/api/directions', {:sensor => false}.merge(params))
    end

    def initialize(origin, destination, params = {})
      @origin = origin
      @destination = destination

      origin = origin.join(',') if Array === origin
      destination = destination.join(',') if Array === destination

      @data = self.class.get(params.merge(:origin => origin, :destination => destination))
    end

    def origin_input
      @origin
    end

    def destination_input
      @destination
    end

    def origin_address
      leg['start_address']
    end

    def destination_address
      leg['end_address']
    end

    def origin_point
      [ leg['start_location']['lat'], leg['start_location']['lng'] ]
    end

    def destination_point
      [ leg['end_location']['lat'], leg['end_location']['lng'] ]
    end

    def status
      @data['status']
    end

    def points
      @points ||= calculate_points
    end

    def distance
      datum = leg['distance']
      datum['value']
    end

    private

    def route
      @data['routes'].first
    end

    def leg
      route['legs'].first
    end

    def points_and_levels
      @points_and_levels ||= calculate_points_and_levels
    end

    def calculate_points_and_levels
      polyline = route['overview_polyline']
      ::GoogleMapsPolyline.decode_polyline(polyline['points'], polyline['levels'])
    end

    def calculate_points
      points_and_levels.map { |lat,lng,level| [lat,lng] }
    end
  end
end
