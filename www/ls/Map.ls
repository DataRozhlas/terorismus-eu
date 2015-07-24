class ig.Map
  (@parentElement, incidents) ->
    @incidents = incidents.filter -> it.latitude and it.longitude
    @incidents.sort (a, b) ->
      | a.date > b.date => 1
      | a.date < b.date => -1
      | otherwise       => 0
    land = topojson.feature do
      ig.data.world
      ig.data.world.objects.land

    countries = topojson.feature do
      ig.data.world
      ig.data.world.objects.countries
    width = 600
    bounds = [[-16.7, 28.1], [34, 60.5]]

    projection = ig.utils.geo.getProjection bounds, width
    {height} = ig.utils.geo.getDimensions bounds, projection
    path = d3.geo.path!
      ..projection projection

    # console.log incidents
    for incident in @incidents
      incident.projected = projection [incident.longitude, incident.latitude]


    @element = @parentElement.append \svg
      ..attr \class \map
      ..attr {width, height}
      ..append \path
        ..attr \class \land
        ..attr \d path land.geometry
      ..selectAll \circle .data @incidents .enter!append \circle
        ..attr \r 4
        ..attr \cx -> it.projected.0
        ..attr \cy -> it.projected.1
        ..transition!
          # ..delay (d, i) -> Math.floor i / 10
        ..attr \class "active"


