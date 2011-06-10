require 'spec'

module ServerSideGoogleMaps
  describe(Route) do
    describe('#initialize') do
      it('should require a 2+-item list') do
        Server.stub('get').and_return({})

        expect { Route.new }.to(raise_exception(ArgumentError))
        expect { Route.new(['point1']) }.to(raise_exception(ArgumentError))
        Route.new(['point1', 'point2'])
      end
    end

    context('with a mocked Directions') do
      class Parser < HTTParty::Parser
        public_class_method(:new)
      end

      before(:each) do
        Directions.stub(:get) do |params|
          basename = if params[:origin] == 'Montreal,QC'
            'directions-Montreal,QC-to-Ottawa,ON.txt'
          else
            'directions-Ottawa,ON-to-Toronto,ON.txt'
          end
            
          data = File.read("#{File.dirname(__FILE__)}/files/#{basename}")
          parser = Parser.new(data, :json)
          parser.parse
        end
      end

      it('should call Directions.new for each leg') do
        Directions.should_receive(:new).with('Montreal,QC', 'Ottawa,ON', {}).ordered
        Directions.should_receive(:new).with('Ottawa,ON', 'Toronto,ON', {}).ordered

        Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
      end

      it('should pass :mode') do
        Directions.should_receive(:new).with('Montreal,QC', 'Ottawa,ON', :mode => :bicycling)

        Route.new(['Montreal,QC', 'Ottawa,ON'], :mode => :bicycling)
      end

      it('should return appropriate origin_input and destination_input') do
        route = Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
        route.origin_input.should == 'Montreal,QC'
        route.destination_input.should == 'Toronto,ON'
      end

      it('should return appropriate origin_address and destination_address') do
        route = Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
        route.origin_address.should == 'Montreal, QC, Canada'
        route.destination_address.should == 'Toronto, ON, Canada'
      end

      it('should return appropriate origin_point and destination_point') do
        route = Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
        route.origin_point.should == Point.new(45.5086700, -73.5536800)
        route.destination_point.should == Point.new(43.65235, -79.3824)
      end

      it('should concatenate the points from component directions') do
        route = Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
        points = route.path.points
        points.length.should == 352
        points[0].should == Point.new(45.50867, -73.55368)
        points[137].should == Point.new(45.4119, -75.69846)
        points[138].should == Point.new(45.40768, -75.69567)
        points[351].should == Point.new(43.65235, -79.3824)
      end

      it('should have the proper distance') do
        route = Route.new(['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'])
        distance = route.distance
        distance.should == 649742
      end

      it('should not alter params') do
        original_params = {
          :mode => :driving,
          :find_shortcuts => [{ :factor => 0.5, :mode => :direct }]
        }
        passed_params = {
          :mode => :driving,
          :find_shortcuts => [{ :factor => 0.5, :mode => :direct }]
        }
        route = Route.new(
          ['Montreal,QC', 'Ottawa,ON', 'Toronto,ON'],
          passed_params
        )
        passed_params.should == original_params
      end
    end
  end
end
