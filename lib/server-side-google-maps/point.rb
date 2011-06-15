module ServerSideGoogleMaps
  class Point
    RADIUS_OF_EARTH = 6367000 # metres
    DEGREES_TO_RADIANS = Math::PI / 180

    attr_reader(:latitude, :longitude, :object, :elevation)
    attr_accessor(:distance_along_path)

    def initialize(latitude, longitude, options = {})
      @latitude = latitude
      @longitude = longitude
      @object = options[:object] if options[:object]
      @distance_along_path = options[:distance_along_path] if options[:distance_along_path]
      @elevation = options[:elevation] if options[:elevation]
    end

    def ==(other)
      return false unless Point === other
      latitude == other.latitude && longitude == other.longitude && object == other.object
    end

    # Calculates the distance to another point, in metres
    #
    # The method assumes the Earth is a sphere.
    def distance(other)
      lat1 = latitude * DEGREES_TO_RADIANS
      lat2 = other.latitude * DEGREES_TO_RADIANS
      dlat = lat2 - lat1
      dlon = (longitude - other.longitude) * DEGREES_TO_RADIANS

      # Optimize a tad. This method is slow.
      sin_dlat = Math.sin(dlat / 2)
      sin_dlon = Math.sin(dlon / 2)

      a = sin_dlat * sin_dlat + Math.cos(lat1) * Math.cos(lat2) * sin_dlon * sin_dlon

      sqrt_a = Math.sqrt(a)

      c = 2 * Math.asin(1.0 < sqrt_a ? 1.0 : sqrt_a)

      (RADIUS_OF_EARTH * c).to_i
    end

    def latlng_distance_squared(other)
      latitude_difference = latitude - other.latitude
      longitude_difference = longitude - other.longitude
      latitude_difference * latitude_difference + longitude_difference * longitude_difference
    end

    def latlng_distance_squared_from_segment(segment)
      p1 = segment.first

      vx = p1.latitude - latitude
      vy = p1.longitude - longitude

      return vx*vx + vy*vy if segment.length2 == 0

      ux = segment.dlat
      uy = segment.dlon

      det = (-vx*ux) + (-vy*uy)

      length2 = segment.length2
      if det < 0 || det > length2
        p2 = segment.last
        # We're outside the line segment
        wx = p2.latitude - latitude
        wy = p2.longitude - longitude

        d1 = vx*vx + vy*vy
        d2 = wx*wx + wy*wy
        return d1 < d2 ? d1 : d2
      end

      det = ux*vy - uy*vx

      return det * det / length2
    end
  end
end
