require 'spec'

module ServerSideGoogleMaps
  describe(Point) do
    describe('#initialize') do
      it('should set latitude and longitude') do
        point = Point.new(1.2, 3.4)
        point.latitude.should == 1.2
        point.longitude.should == 3.4
      end

      it('should work without an "object" option') do
        point = Point.new(1.2, 3.4)
        point.object.should == nil
      end

      it('should work with a "distance_along_path" option') do
        point = Point.new(1.2, 3.4, :distance_along_path => 341)
        point.distance_along_path.should == 341
      end

      it('should work with a "elevation" option') do
        point = Point.new(1.2, 3.4, :elevation => 341)
        point.elevation.should == 341
      end

      it('should allow an "object" option') do
        object = [1, 2, 3]
        point = Point.new(1.2, 3.4, :object => object)
        point.object.should == object
      end
    end

    describe('#latlng_distance_squared') do
      it('should calculate the lat/lng distance squared') do
        point1 = Point.new(1.0, 4.0)
        point2 = Point.new(2.0, 6.0)
        point1.latlng_distance_squared(point2).should == 5.0
      end
    end

    describe('#distance') do
      it('should calculate the distance') do
        point1 = Point.new(1.0, 4.0)
        point2 = Point.new(2.0, 6.0)
        point1.distance(point2).should == 248412
      end
    end
  end
end
