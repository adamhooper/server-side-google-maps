# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "server-side-google-maps/version"

Gem::Specification.new do |s|
  s.name        = "server-side-google-maps"
  s.version     = ServerSideGoogleMaps::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Hooper"]
  s.email       = ["adam@adamhooper.com"]
  s.homepage    = "http://github.com/adamh/server-side-google-maps"
  s.summary     = %q{Performs calculations with Google Maps}
  s.description = %q{Servers can use Google Maps, too. This library helps fetch and parse data through the Google Maps v3 API. Stick to the terms of usage, though, and don't use the data Google gives you on anything other than a Google map.}

  s.add_dependency('httparty')
  s.add_dependency('nayutaya-googlemaps-polyline', '0.0.1')

  s.rubyforge_project = "server-side-google-maps"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
