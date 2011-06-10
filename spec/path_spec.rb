require 'spec'

module ServerSideGoogleMaps
  describe(Path) do
    describe('#get_elevations') do
      it('should use the proper URL') do
        Server.should_receive(:get).with('/maps/api/elevation/json', :query => { :sensor => false, :path => 'abcd', :samples => 20})
        Path.get_elevations(:path => 'abcd', :samples => 20)
      end
    end

    describe('#initialize') do
      it('should not allow a 0-point path') do
        expect { Path.new([]) }.to(raise_exception(ArgumentError))
      end

      it('should allow a 1-point path') do
        pt = Point.new(45.5086700, -73.5536800)
        Path.new([pt])
      end
    end

    context('with a mocked #get_elevations') do
      class Parser < HTTParty::Parser
        public_class_method(:new)
      end

      before(:each) do
        Path.stub(:get_elevations) do |params|
          basename = 'path1-get_elevations-result.txt'
          data = File.read("#{File.dirname(__FILE__)}/files/#{basename}")
          parser = Parser.new(data, :json)
          parser.parse
        end
      end

      describe('#elevations') do
        it('should pass an encoded :path and :samples to #get_elevations') do
          Path.should_receive(:get_elevations).with(:path => 'enc:elwtGn}|_M~piJnlqb@', :samples => 20)
          pt1 = Point.new(45.50867, -73.55368)
          pt2 = Point.new(43.65235, -79.38240)
          path = Path.new([pt1, pt2])
          path.elevations(20)
        end

        it('should return the proper elevations') do
          pt1 = Point.new(45.50867, -73.55368)
          pt2 = Point.new(43.65235, -79.38240)
          path = Path.new([pt1, pt2])
          elevations = path.elevations(20)
          elevations.points.length.should == 20 # the 20 is from the stub file, not the above argument
          elevations.points[0].elevation.should == 15.3455887
          elevations.points[0].latitude.should == 45.50867
          elevations.points[0].longitude.should == -73.55368
          elevations.points[19].elevation.should == 89.6621323
        end
      end
    end

    describe('#calculate_distances') do
      it('should put 0 on a 1-element Path') do
        p1 = Point.new(1.0, 2.0)
        path = Path.new([p1])
        path.calculate_distances
        path.points[0].distance_along_path.should == 0
      end

      it('should calculate the distance for each element') do
        p1 = Point.new(1.0, 2.0)
        p2 = Point.new(4.0, 1.0)
        p3 = Point.new(3.0, 8.0)
        path = Path.new([p1, p2, p3])
        path.calculate_distances
        path.points[0].distance_along_path.should == 0
        path.points[1].distance_along_path.should == 351371
        path.points[2].distance_along_path.should == 1135696
      end
    end

    describe('#interpolate') do
      it('should return a new, interpolated Path with more than the original number of points') do
        p1 = Point.new(1.0, 2.0)
        p2 = Point.new(7.0, 2.0)
        p3 = Point.new(7.0, 1.0)
        path = Path.new([p1, p2, p3])
        interpolated = path.interpolate(8)
        interpolated.length.should == 8
        interpolated[0].should == p1
        interpolated[6].latitude.to_s.should == '6.9936056564358' # too many decimals...
        interpolated[6].longitude.should == 2.0
        interpolated[6].distance_along_path.should == 666039
        interpolated[7].should == p3
      end

      it('should work okay when duplicate Points are on the Path') do
        p1 = Point.new(1.0, 2.0)
        p2 = Point.new(7.0, 2.0)
        p2_2 = Point.new(7.0, 2.0)
        p3 = Point.new(7.0, 1.0)
        path = Path.new([p1, p2, p2_2, p3])
        interpolated = path.interpolate(8)
        interpolated[0].should == p1
        interpolated[6].latitude.to_s.should == '6.9936056564358' # too many decimals...
        interpolated[6].longitude.should == 2.0
        interpolated[6].distance_along_path.should == 666039
        interpolated[7].should == p3
      end

      it('should interpolate elevations') do
        p1 = Point.new(1.0, 1.0, :elevation => 10)
        p2 = Point.new(2.0, 2.0, :elevation => 50)
        path = Path.new([p1, p2])
        interpolated = path.interpolate(5)
        interpolated[0].elevation.should == 10
        interpolated[1].elevation.should == 20
        interpolated[4].elevation.should == 50
      end
    end
  end
end
