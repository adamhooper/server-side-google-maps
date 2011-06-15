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

      i = -1
      total_distance = points.last.distance_along_path

      points = results['results'].collect do |r|
        i += 1
        Point.new(
          r['location']['lat'].to_f,
          r['location']['lng'].to_f,
          :elevation => r['elevation'].to_f,
          :distance_along_path => total_distance && (total_distance.to_f * i / (n - 1)).to_i
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
      ret << create_interpolated_point(points[0], points[0], 0.0, :distance_along_path => points[0].distance_along_path)

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

        ret << create_interpolated_point(point_before, point_after, fraction_after, :distance_along_path => current_distance.to_i)
      end

      ret << create_interpolated_point(points[-1], points[-1], 0.0, :distance_along_path => points[-1].distance_along_path)

      Path.new(ret)
    end

    def simplify(latlng_error2)
      simplified_points = douglas_peucker(points, latlng_error2)
      Path.new(simplified_points)
    end

    private

    def douglas_peucker(points, latlng_error2)
      ret = [points[0]]

      stack = []
      stack.push([0, points.length - 1])

      while !stack.empty?
        left, right = stack.pop

        segment = Segment.new(points[left], points[right])
        max_i = 0
        max_d = 0

        (left...right).each do |i|
          point = points[i]
          d = point.latlng_distance_squared_from_segment(segment)
          if d > max_d
            max_i = i
            max_d = d
          end
        end

        if max_d > latlng_error2
          stack.push([max_i, right])
          stack.push([left, max_i])
        else
          ret << points[right]
        end
      end

      ret
    end

    def create_interpolated_point(point_before, point_after, fraction_after, options = {})
      fraction_before = 1.0 - fraction_after

      if point_before.elevation && point_after.elevation && options[:elevation].nil?
        options = options.merge(:elevation => fraction_before * point_before.elevation + fraction_after * point_after.elevation)
      end

      Point.new(
        fraction_before * point_before.latitude + fraction_after * point_after.latitude,
        fraction_before * point_before.longitude + fraction_after * point_after.longitude,
        options
      )
    end

    def encoded_path
      @encoded_path ||= ::GoogleMapsPolyline::Encoder.new(StringIO.new).encode_points(points_1e5).string
    end

    def points_1e5
      @points.map { |p| [ (p.latitude * 1e5).to_i, (p.longitude * 1e5).to_i ] }
    end
  end
end
