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

    describe('#latlng_distance_squared_from_segment') do
      it('should catch when point is outside segment edges') do
        # p1 ------------*---------
        # p2 --*------------------- <- this point is farther than it'd be if the
        # p3 -------------------*--    line segment were an infinite line
        p1 = Point.new(1.0, 7.0)
        p2 = Point.new(-1.0, 9.1)
        p3 = Point.new(7.0, 1.0)

        distance2 = p2.latlng_distance_squared_from_segment(Segment.new(p1, p3))
        distance2.should == p2.latlng_distance_squared(p1)
      end

      it('should work when segment is a singularity') do
        p1 = Point.new(1.0, 7.0)
        p2 = Point.new(-1.0, 9.1)
        p3 = Point.new(1.0, 7.0)

        distance2 = p2.latlng_distance_squared_from_segment(Segment.new(p1, p3))
        distance2.should == p2.latlng_distance_squared(p1)
      end
    end

    describe('#distance') do
      it('should calculate the distance') do
        point1 = Point.new(1.0, 4.0)
        point2 = Point.new(2.0, 6.0)
        point1.distance(point2).should == 248412
      end
    end

    describe('#==') do
      it('should work with same latitude/longitudes') do
        p1 = Point.new(1, 2)
        p2 = Point.new(1, 2)
        (p1 == p2).should == true
      end

      it('should work with different latitudes/longitudes') do
        p1 = Point.new(1, 2)
        p2 = Point.new(1, 4)
        (p1 == p2).should == false
      end

      it('should work with a non-Point') do
        p1 = Point.new(1, 2)
        (p1 == true).should == false
      end
    end
  end
end
