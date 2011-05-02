module ServerSideGoogleMaps
  class Path
    def self.get_elevations(params)
      server = Server.new
      server.get('/maps/api/elevation', {:sensor => false}.merge(params))
    end

    def initialize(points)
      raise ArgumentError.new('path must be an Enumerable') unless Enumerable === points
      raise ArgumentError.new('path must have one or more points') unless points.length > 0
      i = 0
      @points = points.collect do |pt|
        raise ArgumentError.new("path element #{i} must be a [latitude, longitude] Array") unless pt.length == 2
        pt.dup
      end
    end

    # Returns an Array of n equidistant altitudes (in metres) along this path
    def elevations(n)
      results = self.class.get_elevations(:path => "enc:#{encoded_path}", :samples => n)
      results['results'].collect { |r| r['elevation'].to_f }
    end

    private

    def encoded_path
      @encoded_path ||= ::GoogleMapsPolyline::Encoder.new(StringIO.new).encode_points(points_1e5).string
    end

    def points_1e5
      @points.map { |latitude, longitude| [ (latitude * 1e5).to_i, (longitude * 1e5).to_i ] }
    end
  end
end
