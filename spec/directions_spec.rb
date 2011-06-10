require 'spec'

module ServerSideGoogleMaps
  describe(Directions) do
    describe('#get') do
      it('should use proper URL') do
        Server.should_receive(:get).with('/maps/api/directions/json', :query => { :origin => 'Montreal,QC', :destination => 'Ottawa,ON', :sensor => false })
        Directions.get(:origin => 'Montreal,QC', :destination => 'Ottawa,ON')
      end
    end

    describe('#initialize') do
      it('should query with :origin and :destination when given strings') do
        Directions.should_receive(:get).with(:origin => 'Montreal,QC', :destination => 'Ottawa,ON', :mode => :driving)
        Directions.new('Montreal,QC', 'Ottawa,ON')
      end

      it('should query with :origin and :destination when given points') do
        Directions.should_receive(:get).with(:origin => '45.50867,-73.55368', :destination => '45.4119,-75.69846', :mode => :driving)
        Directions.new([45.5086700,-73.5536800], [45.4119000,-75.6984600])
      end

      it('should pass :mode') do
        Directions.should_receive(:get).with(:origin => '1', :destination => '2', :mode => :bicycling)
        Directions.new('1', '2', :mode => :bicycling)
      end

      it('should not query Google with :direct and lat-lng string inputs') do
        Directions.should_not_receive(:get)
        Directions.new('45.5086700,-73.5536800', '45.4119000,-75.6984600', :mode => :direct)
      end

      it('should not query Google with :direct and lat-lng inputs') do
        Directions.should_not_receive(:get)
        Directions.new([45.5086700,-73.5536800], [45.4119000,-75.6984600], :mode => :direct)
      end
    end

    context('with lat-lng string inputs and :mode => :direct') do
      it('should calculate proper distance') do
        directions = Directions.new('45.5086700,-73.5536800', '45.4119000,-75.6984600', :mode => :direct)
        directions.distance.should == 167512
      end
    end

    context('with a mocked return value') do
      class Parser < HTTParty::Parser
        public_class_method(:new)
      end

      before(:each) do
        Directions.stub(:get) do
          data = File.read(File.dirname(__FILE__) + '/files/directions-Montreal,QC-to-Ottawa,ON.txt')
          parser = Parser.new(data, :json)
          parser.parse
        end
      end

      it('should have origin_input and destination_input') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.origin_input.should == 'Montreal,QC'
        directions.destination_input.should == 'Ottawa,ON'
      end

      it('should have (server-supplied) origin_address and destination_input') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.origin_address.should == 'Montreal, QC, Canada'
        directions.destination_address.should == 'Ottawa, ON, Canada'
      end

      it('should have origin_point and destination_point') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.origin_point.should == Point.new(45.5086700, -73.5536800)
        directions.destination_point.should == Point.new(45.4119000, -75.6984600)
      end

      it('should have an "OK" status') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.status.should == 'OK'
      end

      it('should have the proper points') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        points = directions.path.points
        points.length.should == 138
        points[0].should == Point.new(45.50867, -73.55368)
        points[1].should == Point.new(45.50623, -73.55569)
        points[-1].should == Point.new(45.4119, -75.69846)
      end

      it('should have the proper distance') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        distance = directions.distance
        distance.should == 199901
      end

      it('should suggest a straight line, with :direct') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON', :mode => :direct)
        directions.path.points.should == [Point.new(45.50867, -73.55368), Point.new(45.4119, -75.69846)]
        directions.distance.should == 167512
      end

      it('should suggest normal route if :find_shortcuts shortcuts are not short enough') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON', :find_shortcuts => [{ :factor => 0.5, :mode => :direct }])
        directions.path.points.length.should > 2
        directions.distance.should == 199901
      end

      it('should suggest a shortcut if :find_shortcuts finds a shortcut') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON', :find_shortcuts => [{ :factor => 0.95, :mode => :direct }])
        directions.path.points.length.should == 2
        directions.distance.should == 167512
      end

      it('should correct the user if :find_shortcuts is not an Array') do
        lambda { Directions.new('Montreal,QC', 'Ottawa,ON', :find_shortcuts => { :factor => 0.5, :mode => :direct }) }.should(raise_error(ArgumentError))
      end
    end

    context('when Google forgets the total distance') do
      class Parser < HTTParty::Parser
        public_class_method(:new)
      end

      before(:each) do
        Directions.stub(:get) do
          data = File.read(File.dirname(__FILE__) + '/files/directions-Montreal,QC-to-Ottawa,ON-without-distance.txt')
          parser = Parser.new(data, :json)
          parser.parse
        end
      end

      it('should calculate the distance by summing the parts') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.distance.should == 199901
      end
    end

    context('when Google forgets the overview polyline') do
      class Parser < HTTParty::Parser
        public_class_method(:new)
      end

      before(:each) do
        Directions.stub(:get) do
          data = File.read(File.dirname(__FILE__) + '/files/directions-Montreal,QC-to-Ottawa,ON-without-overview-polyline.txt')
          parser = Parser.new(data, :json)
          parser.parse
        end
      end

      it('should provide the start-point and end-point instead') do
        directions = Directions.new('Montreal,QC', 'Ottawa,ON')
        directions.path.points.should == [Point.new(45.50867, -73.55368), Point.new(45.4119, -75.69846)]
      end
    end
  end
end
