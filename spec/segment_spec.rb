require 'spec'

module ServerSideGoogleMaps
  describe(Segment) do
    describe('#first') do
      it('should return the first element') do
        point1 = Point.new(1, 2)
        point2 = Point.new(2, 3)
        segment = Segment.new(point1, point2)
        segment.first.should == point1
      end
    end

    describe('#last') do
      it('should return the last element') do
        point1 = Point.new(1, 2)
        point2 = Point.new(2, 3)
        segment = Segment.new(point1, point2)
        segment.last.should == point2
      end
    end

    describe('#length2') do
      it('should return the length squared') do
        point1 = Point.new(1, 2)
        point2 = Point.new(2, 3)
        segment = Segment.new(point1, point2)
        segment.length2.should == 2
      end

      it('should return 0 for zero-length segment') do
        point = Point.new(1, 2)
        segment = Segment.new(point, point)
        segment.length2.should == 0
      end
    end

    describe('#to_a') do
      it('should return the array') do
        p1 = Point.new(1, 2)
        p2 = Point.new(2, 3)
        segment = Segment.new(p1, p2)
        a = segment.to_a
        a.length.should == 2
        a[0].should == p1
        a[1].should == p2
      end
    end
  end
end
