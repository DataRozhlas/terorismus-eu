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
    width = 700
    bounds = [[-16.7, 15], [37, 60.5]]

    projection = ig.utils.geo.getProjection bounds, width
    {height} = ig.utils.geo.getDimensions bounds, projection
    path = d3.geo.path!
      ..projection projection

    for incident in @incidents
      incident.projected = projection [incident.longitude, incident.latitude]

    @element = @parentElement.append \svg
      ..attr \class \map
      ..attr {width, height}
      ..append \path
        ..attr \class \land
        ..attr \d path land.geometry
    @incidentElements = @element.selectAll \circle .data @incidents .enter!append \circle
        ..attr \r 4
        ..attr \cx -> it.projected.0
        ..attr \cy -> it.projected.1
        ..attr \fill -> it.group.color

  updateDownlighting: ->
    @incidentElements.classed \downlight -> it.downlight
