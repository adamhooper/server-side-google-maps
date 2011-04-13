module ServerSideGoogleMaps
  class Route
    def initialize(points, params = {})
      raise ArgumentError if points.length < 2

      @directionses = points[0..-2].zip(points[1..-1]).map do |origin, destination|
        Directions.new(origin, destination, params)
      end
    end

    def origin_input
      @directionses.first.origin_input
    end

    def destination_input
      @directionses.last.destination_input
    end

    def origin_address
      @directionses.first.origin_address
    end

    def destination_address
      @directionses.last.destination_address
    end

    def origin_point
      @directionses.first.origin_point
    end

    def destination_point
      @directionses.last.destination_point
    end

    def points
      @points ||= calculate_points
    end

    def distance
      @distance ||= @directionses.map{|d| d.distance}.inject(:+)
    end

    private

    def calculate_points
      pointses = @directionses.map { |d| d.points }

      first = pointses.shift

      first + pointses.map{ |p| p[1..-1] }.flatten(1)
    end
  end
end
