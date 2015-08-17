radius = 3
cellsPerRow = 7
margin = 1
yearWidth = 21
bottomPadding = 25
class ig.Years
  (@parentElement, @years, @bigIncidents, @groupsAssoc) ->
    ig.Events @
    @element = @parentElement.append \div
      ..attr \class \years
      ..selectAll \div.year .data @years .enter!append \div
        ..attr \class \year
        ..filter(-> 0 == it.year % 5)
          ..append \span
            ..attr \class \title
            ..html -> it.year
    @incidentsParent = @element.append \div
      ..attr \class \incidents-parent
    @detailedIncidentParent = @element.append \div
      ..attr \class "incidents-parent detailed-incidents"
    @resortYears!
    @updateGraph!
    @drawCanvasOverlay!
    @element.append \div
      ..attr \class \year-notice
      ..html "V datech bohužel chybí rok 1993, kdy ale na evropském území podle jiných zdrojů nedošlo k žádnému útoku s velkým počtem obětí"

  updateDownlighting: ->
    @clearDetailedIncidents!
    @allIncidentElements.classed \entering no
    @allIncidentElements.classed \downlight -> it.downlight
    <~ setTimeout _, 1200
    @updateGraph!

  cancelGroupHighlight: ->
    @allIncidentElements.classed \downlight no

  resortYears: ->
    for year in @years
      year.incidentsByGroup.sort (a, b) ->
        a.group.yearSortIndex - b.group.yearSortIndex
      previousDeaths = 0
      for group in year.incidentsByGroup
        for incident in group.list
          incident.previousDeaths = previousDeaths
          previousDeaths += incident.deaths
    @repositionIncidents!

  updateGraph: ->
    @bigIncidents.sort (a, b) -> a.previousDeaths - b.previousDeaths
    intros = @bigIncidents.filter -> it.introStartX - it.introEndX
    outros = @bigIncidents.filter -> it.outroStartX - it.outroEndX
    mains  = @bigIncidents.filter -> it.mainStartX - it.mainEndX
    @incidentsParent.selectAll \div.incident.intro .data intros, (.id)
      ..enter!append \div
        ..attr \class ->
          "intro incident entering #{if it.downlight then 'downlight' else ''}"
      ..exit!remove!
      ..style \left (d) -> "#{d.year.index * yearWidth +  radius * d.introStartX}px"
      ..style \bottom (d) -> "#{radius * d.introY}px"
      ..style \width (d) ->
        w = radius * (d.introEndX - d.introStartX)
        w-- if d.introEndX == cellsPerRow
        "#{w}px"

    @incidentsParent.selectAll \div.incident.outro .data outros, (.id)
      ..enter!append \div
        ..attr \class ->
          "outro incident entering #{if it.downlight then 'downlight' else ''}"
      ..exit!remove!
      ..style \left (d) -> "#{d.year.index * yearWidth +  radius * d.outroStartX}px"
      ..style \bottom (d) -> "#{radius * d.outroY}px"
      ..style \width (d) ->
        w = radius * (d.outroEndX - d.outroStartX)
        w-- if d.outroEndX == cellsPerRow
        "#{w}px"

    @incidentsParent.selectAll \div.incident.main .data mains, (.id)
      ..enter!append \div
        ..attr \class ->
          "main incident entering #{if it.downlight then 'downlight' else ''}"
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
      ..on \mouseout ~> @downlightIncident it

  repositionIncidents: ->
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

  highlightIncident: (incident) ->
    @downlightIncident!
    return if incident.downlight
    @highlightedIncident = incident
    if incident.isOther
      @fillUpOtherElement incident
    else
      @emit \highlight incident
    @highlightedItems = @allIncidentElements
      .filter (-> it is incident)
      .style \background-color ->
        it.group.lightColor

  fillUpOtherElement: (containerIncident) ->
    deaths = []
    previousDeaths = containerIncident.previousDeaths
    self = @
    for incident in containerIncident.list
      for death in [1 to incident.deaths]
        deaths.push do
          order: previousDeaths
          x: previousDeaths % cellsPerRow
          y: Math.floor previousDeaths / cellsPerRow
          incident: incident
        previousDeaths++
    @currentDetailedIncidents = @detailedIncidentParent.selectAll \div .data deaths
      ..enter!append \div
        ..attr \class \incident
      ..exit!remove!
      ..classed \last -> it.x == cellsPerRow - 1
      ..style \left (d) -> "#{d.incident.year.index * yearWidth + radius * d.x}px"
      ..style \bottom (d) -> "#{radius * d.y}px"
      ..style \background-color -> it.incident.group.color
      ..on \mouseover ->
        @style.backgroundColor = it.incident.group.lightColor
        self.emit \highlight it.incident
      ..on \touchstart ->
        self.emit \highlight it.incident
        self.currentDetailedIncidents.style \background-color -> it.incident.group.color
        @style.backgroundColor = it.incident.group.lightColor
      ..on \mouseout ->
        @style.backgroundColor = it.incident.group.color
        self.emit \downlight


  clearDetailedIncidents: ->
    @detailedIncidentParent.selectAll \div .remove!

  downlightIncident: (incident = @highlightedIncident) ->
    if @highlightedItems
      @emit \downlight
      that.style \background-color -> it.group.color


  drawCanvasOverlay: ->
    height = 63 * radius
    width = @years.length * yearWidth
    canvas = @element.append \canvas
      ..attr \width 1024
      ..attr \height height
    ctx = canvas.node!getContext \2d
    ctx.translate -0.5, 0.5
    ctx.beginPath!
    for year, yearIndex in @years
      for cellIndex in [1 til cellsPerRow]
        x = yearIndex * yearWidth + cellIndex * radius
        ctx.moveTo x, height - (Math.ceil year.deaths / cellsPerRow) * radius
        ctx.lineTo x, height
    for i in [1 to 62]
      y = i * radius
      ctx.moveTo 0, height - y
      ctx.lineTo width, height - y
    ctx.stroke!
