module ServerSideGoogleMaps
  class Segment
    attr_reader(:first, :last)

    def initialize(point1, point2)
      @first = point1
      @last = point2
    end

    def dlat
      @dlat ||= last.latitude - first.latitude
    end

    def dlon
      @dlon ||= last.longitude - first.longitude
    end

    def length2
      @length2 ||= dlat * dlat + dlon * dlon
    end

    def to_a
      [first, last]
    end

    private

    def calculate_length2
    end
  end
end
