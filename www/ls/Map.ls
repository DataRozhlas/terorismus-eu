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

    countriesMesh = topojson.mesh do
      ig.data.staty
      ig.data.staty.objects.data
      (a, b) -> a isnt b

    @width = width = 700
    bounds = [[-16.7, 15], [37, 60.5]]

    console.log d3.max @incidents.map (.latitude)

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
      ..append \path
        ..attr \class \boundaries
        ..attr \d path countriesMesh

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

  drawHighlightCircles: (incident) ->
    if @unHighlightTimeout
      clearTimeout @unHighlightTimeout
      @unHighlightTimeout = null
    @importantIncidentsG.classed \hidden yes
    return unless incident.projected
    @highlightCircles = @highlightCirclesG.selectAll \circle .data [incident]
      ..enter!append \circle
        ..attr \r 9
      ..exit!remove!
      ..attr \cx -> it.projected.0
      ..attr \cy -> it.projected.1

  unHighlight: ->
    return if @unHighlightTimeout
    @unHighlightTimeout = setTimeout do
      ~>
        @unHighlightTimeout = null
        @highlightCircles.remove! if @highlightCircles
        @importantIncidentsG.classed \hidden no
      200

  updateDownlighting: ->
    @incidentElements.classed \downlight -> it.downlight
    @drawImportantIncindents!

  drawImportantIncindents: ->
    @importantIncidents = @incidents.filter -> !it.downlight && it.text
    voronoi = d3.geom.voronoi!
      ..x ~> it.projected.0
      ..y ~> it.projected.1
      ..clipExtent [[81, 0], [@width, @height]]
    voronoiPolygons = voronoi @importantIncidents .filter -> it
    @voronoiG.selectAll \path .remove!
    @voronoiG.selectAll \path .data voronoiPolygons .enter!append \path
      .attr \d -> polygon it
      .on \mouseover ~> @highlightImportantIncident it.point
      .on \touchstart ~> @highlightImportantIncident it.point
      .on \mouseout ~> @downlightImportantIncident!

    @importantIncidentsCircles = @importantIncidentsG.selectAll \circle .data @importantIncidents
      ..enter!append \circle
        ..attr \r 9
      ..exit!remove!
      ..attr \cx -> it.projected.0
      ..attr \cy -> it.projected.1

  highlightImportantIncident: (incident) ->
    console.log incident
    @importantIncidentsCircles.classed \highlighted -> it is incident
    @emit \importantIncident incident

  downlightImportantIncident: ->
    @importantIncidentsCircles.classed \highlighted no
    @emit \importantIncidentOut



polygon = ->
  "M#{it.join "L"}Z"
