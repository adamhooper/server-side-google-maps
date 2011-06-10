# Server-Side Google Maps: map data from Google, for your server

Make requests for direction from Google's servers, and receive them in a
Ruby-usable object.

## Installation and usage

To install:

    sudo gem install server-side-google-maps

Then, to use within Ruby:

    route = ServerSideGoogleMaps::Route.new(['Montreal, QC', 'Ottawa, ON'], :mode => :driving)
    # Origin and destination accept [lat,lon] coordinates as well as strings
    # :mode => :driving is the default. Others are :bicycling and :walking

    route.status              # 'OK'
    route.origin_address      # 'Montreal, QC, Canada'
    route.origin_point        # [ 45.5086700, -73.5536800 ]
    route.destination_address # 'Ottawa, ON, Canada'
    route.destination_point   # [ 45.4119000, -75.6984600 ]
    route.path.points         # Array of Point coordinates of route
    route.points[0].latitude  # .latitude, .longitude, .distance_to_here
    route.distance            # 199901 (metres)

    # We can also find elevations along a path
    path = route.path
    path.elevations(20) # Array of equidistant Points, each with an elevation
    # Paths used for elevation may only be up to around 230 points long,
    # to comply with Google's URL length limit. That's not hard to achieve:
    simple_path = path.interpolate(230) # will create a new Path by interpolating

One final `:mode` is `:direct`, which calculates `points` and estimates
`distance` without querying Google. To ensure Google isn't queried, input
the origin and destination as latitude/longitude coordinates.

## Limitations

As per the Google Maps API license agreement, the data returned from the
Google Maps API must be used only for display on a Google Map.

I'll write that again: Google Maps data is for Google Maps only! You may not
do any extra calculating and processing, unless the results of those extra
calculations are displayed on a Google Map.

There are also query limits on each Google API, on the order of a few thousand
queries each day. Design your software accordingly. (Cache heavily and don't
query excessively.)

## Development

Each feature and issue must have a spec. Please write specs if you can.
