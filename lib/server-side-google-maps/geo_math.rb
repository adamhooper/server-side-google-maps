module ServerSideGoogleMaps
  module GeoMath
    RADIUS_OF_EARTH = 6367000 # metres

    # Returns the distance (in m) between two [lat,lng] points with the Haversine formula
    def self.latlng_distance(pt1, pt2)
      lat1 = pt1[0] * Math::PI / 180
      lon1 = pt1[1] * Math::PI / 180
      lat2 = pt2[0] * Math::PI / 180
      lon2 = pt2[1] * Math::PI / 180
      dlon = lon2 - lon1
      dlat = lat2 - lat1
      a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
      c = 2 * Math.asin(min(1.0, Math.sqrt(a)))
      (RADIUS_OF_EARTH * c).to_i
    end

    private

    def self.min(f1, f2)
      f1 < f2 ? f1 : f2
    end
  end
end
