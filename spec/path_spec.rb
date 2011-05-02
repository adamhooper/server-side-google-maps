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
        pt = [ 45.5086700, -73.5536800 ]
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
          pt1 = [ 45.50867, -73.55368 ]
          pt2 = [ 43.65235, -79.38240 ]
          path = Path.new([pt1, pt2])
          path.elevations(20)
        end

        it('should return the proper elevations') do
          pt1 = [ 45.50867, -73.55368 ]
          pt2 = [ 43.65235, -79.38240 ]
          path = Path.new([pt1, pt2])
          elevations = path.elevations(20)
          elevations.length.should == 20 # the 20 is from the stub file, not the above argument
          elevations[0].should == 15.3455887
          elevations[19].should == 89.6621323
        end
      end
    end
  end
end
