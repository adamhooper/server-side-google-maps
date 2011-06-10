module ServerSideGoogleMaps
  class Path
    attr_reader(:points)

    def self.get_elevations(params)
      server = Server.new
      server.get('/maps/api/elevation', {:sensor => false}.merge(params))
    end

    def initialize(points)
      raise ArgumentError.new('path must be an Enumerable') unless Enumerable === points
      raise ArgumentError.new('path must have one or more points') unless points.length > 0
      i = 0
      @points = points.collect do |pt|
        raise ArgumentError.new("path element #{i} must have .latitude and .longitude") unless pt.respond_to?(:latitude)
        pt
      end
    end

    # Returns a new Path with n equidistant Points along this Path, complete with .elevation
    def elevations(n)
      results = self.class.get_elevations(:path => "enc:#{encoded_path}", :samples => n)
      points = results['results'].collect do |r|
        Point.new(
          r['location']['lat'].to_f,
          r['location']['lng'].to_f,
          :elevation => r['elevation'].to_f
        )
      end
      Path.new(points)
    end

    # Sets .distance on every Point in the Path
    #
    # Yes, this is a hack: it assumes all the Points will only belong to this Path.
    # It's here because it's convenient.
    def calculate_distances
      total_distance = 0
      last_point = nil
      points.each do |point|
        if last_point
          distance_piece = last_point.distance(point)
          total_distance += distance_piece
        end
        point.distance_along_path = total_distance
        last_point = point
      end
    end

    # Returns a Path that approximates this one, with n points
    def interpolate(n)
      calculate_distances unless points[0].distance_along_path

      total_distance = points[-1].distance_along_path - points[0].distance_along_path
      distance_step = 1.0 * total_distance / (n - 1)

      ret = []
      ret << Point.new(
        points[0].latitude,
        points[0].longitude,
        :distance_along_path => points[0].distance_along_path
      )

      j = 0
      current_distance = points[0].distance_along_path
      (1...(n - 1)).each do |i|
        current_distance += distance_step if i > 0
        while j < (points.length - 2) && points[j + 1].distance_along_path < current_distance #&& points[j].distance_along_path == points[j + 1].distance_along_path
          j += 1
        end

        point_before = points[j]
        point_after = points[j + 1]
        point_segment_length = point_after.distance_along_path - point_before.distance_along_path

        fraction_after = (1.0 * current_distance - point_before.distance_along_path) / point_segment_length
        fraction_before = 1.0 - fraction_after

        ret << Point.new(
          fraction_before * point_before.latitude + fraction_after * point_after.latitude,
          fraction_before * point_before.longitude + fraction_after * point_after.longitude,
          :distance_along_path => current_distance.round
        )
      end

      ret << Point.new(
        points[-1].latitude,
        points[-1].longitude,
        :distance_along_path => points[-1].distance_along_path
      )
    end

    private

    def encoded_path
      @encoded_path ||= ::GoogleMapsPolyline::Encoder.new(StringIO.new).encode_points(points_1e5).string
    end

    def points_1e5
      @points.map { |p| [ (p.latitude * 1e5).to_i, (p.longitude * 1e5).to_i ] }
    end
  end
end
