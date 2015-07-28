class ig.Map
  (@parentElement, incidents) ->
    ig.Events @
    @incidents = incidents.filter -> it.latitude and it.longitude
    @incidents.sort (a, b) ->
      | a.date > b.date => 1
      | a.date < b.date => -1
      | otherwise       => 0
    land = topojson.feature do
      ig.data.evropa
      ig.data.evropa.objects.data

    @width = width = 700
    bounds = [[-16.7, 15], [37, 60.5]]

    projection = ig.utils.geo.getProjection bounds, width
    {height} = ig.utils.geo.getDimensions bounds, projection
    @height = height
    path = d3.geo.path!
      ..projection projection

    for incident in @incidents
      incident.projected = projection [incident.longitude, incident.latitude]

    @element = @parentElement.append \svg
      ..attr \class \map
      ..attr {width, height}
      ..append \path
        ..attr \class \land
        ..attr \d path land.features.0.geometry
    @incidentsG = @element.append \g
      ..attr \class \incidents
    @incidentElements = @incidentsG.selectAll \circle .data @incidents .enter!append \circle
        ..attr \r 4
        ..attr \cx -> it.projected.0
        ..attr \cy -> it.projected.1
        ..attr \fill -> it.group.color
    @highlightCirclesG = @element.append \g
      ..attr \class \highlight-circles
    @importantIncidentsG = @element.append \g
      ..attr \class \important-circles
    @voronoiG = @element.append \g
      ..attr \class \voronoi
    @drawImportantIncindents!

  drawHighlightCircles: (incidents) ->
    clearTimeout @unHighlightTimeout if @unHighlightTimeout
    incidents .= filter (.projected)
    @highlightCircles = @highlightCirclesG.selectAll \circle .data incidents
      ..enter!append \circle
        ..attr \r 9
      ..exit!remove!
      ..attr \cx -> it.projected.0
      ..attr \cy -> it.projected.1

  unHighlight: ->
    return if @unHighlightTimeout
    @unHighlightTimeout = setTimeout do
      ~>
        @highlightCircles.remove!
      200

  updateDownlighting: ->
    @incidentElements.classed \downlight -> it.downlight

  drawImportantIncindents: ->
    @importantIncidents = @incidents.filter -> it.text
    voronoi = d3.geom.voronoi!
      ..x ~> it.projected.0
      ..y ~> it.projected.1
      ..clipExtent [[81, 0], [@width, @height]]
    voronoiPolygons = voronoi @importantIncidents .filter -> it
    @voronoiG.selectAll \path .data voronoiPolygons .enter!append \path
      .attr \d -> polygon it
      .on \mouseover ~> @emit \importantIncident it.point
      .on \touchstart ~> @emit \importantIncident it.point
      .on \mouseout ~> @emit \importantIncidentOut

    @importantIncidentsG.selectAll \circle .data @importantIncidents .enter!append \circle
      ..attr \r 9
      ..attr \cx -> it.projected.0
      ..attr \cy -> it.projected.1



polygon = ->
  "M#{it.join "L"}Z"
