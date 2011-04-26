# Server-Side Google Maps: map data from Google, for your server

Make requests for direction from Google's servers, and receive them in a
Ruby-usable object.

## Installation and usage

To install:

    sudo gem install server-side-google-maps

Then, to use within Ruby:

    directions = Directions.new('Montreal, QC', 'Ottawa, ON', :mode => :driving)
    # Origin and destination accept [lat,lon] coordinates as well as strings
    # :mode => :driving is the default. Others are :bicycling and :walking

    directions.status              # 'OK'
    directions.origin_address      # 'Montreal, QC, Canada'
    directions.origin_point        # [ 45.5086700, -73.5536800 ]
    directions.destination_address # 'Ottawa, ON, Canada'
    directions.destination_point   # [ 45.4119000, -75.6984600 ]
    directions.points              # List of [lat,lon] coordinates of route
    directions.distance            # 199901 (metres)

    route = Route.new(['Montreal, QC', 'Ottawa, ON', 'Toronto, ON'], :mode => :bicycling)
    # All the same methods apply to route as to directions

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
