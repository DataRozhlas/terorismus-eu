radius = 3
cellsPerRow = 7
margin = 1
yearWidth = 21
bottomPadding = 25
class ig.Years
  (@parentElement, @years, @bigIncidents, @groupsAssoc) ->
    @resortYears!
    @element = @parentElement.append \div
      ..attr \class \years
      ..selectAll \div.year .data @years .enter!append \div
        ..attr \class \year
        ..filter(-> 0 == it.year % 5)
          ..append \span
            ..attr \class \title
            ..html -> it.year
    @bigIncidents.sort (a, b) -> a.previousDeaths - b.previousDeaths
    intros = @bigIncidents.filter -> it.introStartX - it.introEndX
    outros = @bigIncidents.filter -> it.outroStartX - it.outroEndX
    mains  = @bigIncidents.filter -> it.mainStartX - it.mainEndX
    @incidentsParent = @element.append \div
      ..attr \class \incidents-parent
    @incidentsParent.selectAll \div.incident.intro .data intros, (.id)
      ..enter!append \div
        ..attr \class "incident intro"
      ..exit!remove!
      ..style \left (d) -> "#{d.year.index * yearWidth +  radius * d.introStartX}px"
      ..style \bottom (d) -> "#{radius * d.introY}px"
      ..style \width (d) ->
        w = radius * (d.introEndX - d.introStartX)
        w-- if d.introEndX == cellsPerRow
        "#{w}px"

    @incidentsParent.selectAll \div.incident.outro .data outros, (.id)
      ..enter!append \div
        ..attr \class "incident outro"
      ..exit!remove!
      ..style \left (d) -> "#{d.year.index * yearWidth +  radius * d.outroStartX}px"
      ..style \bottom (d) -> "#{radius * d.outroY}px"
      ..style \width (d) ->
        w = radius * (d.outroEndX - d.outroStartX)
        w-- if d.outroEndX == cellsPerRow
        "#{w}px"

    @incidentsParent.selectAll \div.incident.main .data mains, (.id)
      ..enter!append \div
        ..attr \class "incident main"
      ..exit!remove!
      ..style \left (d) -> "#{d.year.index * yearWidth +  radius * d.mainStartX}px"
      ..style \bottom (d) -> "#{radius * d.mainStartY}px"
      ..style \width (d) ->
        w = radius * (d.mainEndX - d.mainStartX)
        w-- if d.mainEndX == cellsPerRow
        "#{w}px"
      ..style \height (d) -> "#{radius * (d.mainEndY - d.mainStartY)}px"

    @allIncidentElements = @incidentsParent.selectAll ".incident"
      ..style \background-color -> it.group.color
      ..on \mouseover ~> @highlightIncident it
    @drawCanvasOverlay!

  resortYears: (deferGroupId) ->
    for id, group of @groupsAssoc
      if id != deferGroupId
        group.yearSortIndex = group.index
      else
        group.yearSortIndex = -1
    for year in @years
      year.incidentsByGroup.sort (a, b) ->
        a.group.yearSortIndex - b.group.yearSortIndex
      previousDeaths = 0
      for group in year.incidentsByGroup
        for incident in group.list
          incident.previousDeaths = previousDeaths
          previousDeaths += incident.deaths
    @repositionIncidents!

  repositionIncidents: ->
    # inc =
    #   previousDeaths: 1
    #   deaths: 6
    # @bigIncidents = [inc]
    for incident in @bigIncidents
      start = incident.previousDeaths
      end = incident.previousDeaths + incident.deaths
      startX = start % cellsPerRow
      startY = Math.floor start / cellsPerRow
      endX = end % cellsPerRow
      endY = Math.floor end / cellsPerRow
      incident.introStartX = startX
      incident.introEndX   = startX
      incident.introY      = startY

      incident.outroStartX = endX
      incident.outroEndX   = endX
      incident.outroY      = endY

      incident.mainStartX      = startX
      incident.mainStartY      = startY
      incident.mainEndX        = endX
      incident.mainEndY        = endY + 1
      if endY - startY == 1
        incident.introStartX = startX
        incident.introEndX   = cellsPerRow
        incident.outroStartX = 0
        incident.outroEndX   = endX

        incident.mainEndX        = startX
        incident.mainEndY        = startY
      else if endY - startY > 1
        if startX > 0
          incident.introStartX = startX
          incident.introEndX   = cellsPerRow
          incident.introY      = startY
          incident.mainStartY += 1
        if endX < cellsPerRow
          incident.outroStartX = 0
          incident.outroEndX   = endX
          incident.outroY      = endY
        incident.mainStartX = 0
        incident.mainEndX   = cellsPerRow
        incident.mainEndY   = endY

    # console.log "Intro", inc.introStartX, inc.introEndX, inc.introY
    # console.log "Main", inc.mainStartX, inc.mainEndX, inc.mainStartY, inc.mainEndY
    # console.log "Outro", inc.outroStartX, inc.outroEndX, inc.outroY

  highlightIncident: (incident) ->
    if @highlightedItems
      that.style \background-color -> it.group.color
    @highlightedItems = @allIncidentElements
      .filter (-> it is incident)
      .style \background-color ->
        it.group.lightColor

  drawCanvasOverlay: ->
    height = 240
    width = 1024
    canvas = @element.append \canvas
      ..attr \width 1024
      ..attr \height 240
    ctx = canvas.node!getContext \2d
    ctx.translate -0.5, 0.5
    ctx.beginPath!
    for year, yearIndex in @years
      for cellIndex in [1 til cellsPerRow]
        x = yearIndex * yearWidth + cellIndex * radius
        ctx.moveTo x, 0
        ctx.lineTo x, height
    for i in [1 to 62]
      y = i * radius
      ctx.moveTo 0, height - y
      ctx.lineTo width, height - y
    ctx.stroke!
