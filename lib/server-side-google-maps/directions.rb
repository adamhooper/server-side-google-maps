module ServerSideGoogleMaps
  class Directions
    LATLNG_STRING_REGEXP = /(-?\d+(\.?\d+)?),(-?\d+(\.?\d+)?)/

    def self.get(params)
      server = Server.new
      server.get('/maps/api/directions', {:sensor => false}.merge(params))
    end

    # Initializes directions
    #
    # Parameters:
    # origin: string or [lat,lng] of the first point
    # destination: string or [lat,lng] of the last point
    # params:
    #   :mode: :driving, :bicycling and :walking will be passed to Google Maps.
    #          Another option, :direct, will avoid in-between points and calculate
    #          the distance using the Haversine formula. Defaults to :driving.
    #   :find_shortcuts: [ {:factor => Float, :mode => :a_mode}, ... ]
    #                    For each list item (in the order given), determines if
    #                    using given :mode will cut the distance to less than
    #                    :factor and if so, chooses it. For example, if :mode is
    #                    :bicycling and there's a huge detour because of a missing
    #                    bike lane, pass { :factor => 0.5, :mode => :driving }
    #                    and if a shortcut cuts the distance in half that route
    #                    will be chosen instead.
    def initialize(origin, destination, params = {})
      @origin = origin
      @destination = destination
      params = params.dup
      find_shortcuts = params.delete(:find_shortcuts) || []
      raise ArgumentError.new(':find_shortcuts must be an Array') unless Array === find_shortcuts
      @direct = params[:mode] == :direct
      params[:mode] = :driving if params[:mode] == :direct || params[:mode].nil?

      origin = origin.join(',') if Array === origin
      destination = destination.join(',') if Array === destination

      unless @direct && origin_point_without_server && destination_point_without_server
        @data = self.class.get(params.merge(:origin => origin, :destination => destination))
      end

      if !@direct
        find_shortcuts.each do |try_shortcut|
          factor = try_shortcut[:factor]
          mode = try_shortcut[:mode]

          other = Directions.new(origin, destination, params.merge(:mode => mode))
          if other.distance.to_f / distance < factor
            @points = other.points
            @distance = other.distance
          end
        end
      end
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
      @origin_point ||= origin_point_without_server || [ leg['start_location']['lat'], leg['start_location']['lng'] ]
    end

    def destination_point
      @destination_point ||= destination_point_without_server || [ leg['end_location']['lat'], leg['end_location']['lng'] ]
    end

    def status
      @data['status']
    end

    def points
      @points ||= calculate_points
    end

    def distance
      @distance ||= calculate_distance
    end

    def estimated_distance
      @estimated_distance ||= calculate_estimated_distance
    end

    private

    def origin_point_without_server
      calculate_point_without_server_or_nil(origin_input)
    end

    def destination_point_without_server
      calculate_point_without_server_or_nil(destination_input)
    end

    def calculate_point_without_server_or_nil(input)
      return input if Array === input
      m = LATLNG_STRING_REGEXP.match(input)
      return [ m[1].to_f, m[3].to_f ] if m
    end

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
      return [ origin_point + [0], destination_point + [0]] unless polyline && polyline['points'] && polyline['levels']
      ::GoogleMapsPolyline.decode_polyline(polyline['points'], polyline['levels'])
    end

    def calculate_points
      return [ origin_point, destination_point ] if @direct
      points = points_and_levels.map { |lat,lng,level| [lat,lng] }
      points
    end

    def calculate_distance
      return estimated_distance if @direct
      if !leg['distance']
        return leg['steps'].collect{|s| s['distance']}.collect{|d| d ? d['value'].to_i : 0}.inject(0){|s,v| s += v}
      end
      leg['distance']['value']
    end

    def calculate_estimated_distance
      d = 0
      last_point = points[0]

      points[1..-1].each do |point|
        d += GeoMath.latlng_distance(last_point, point)
        last_point = point
      end

      d
    end
  end
end
