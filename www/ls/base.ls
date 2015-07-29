body = d3.select 'body'
{data, groups: groupsAssoc} = ig.getData!
container = d3.select ig.containers.base
groups = []
for name, group of groupsAssoc
  groups[group.index] = group

bigIncidents = []
combinedIncidentsAndContainers = data.slice!
years = [1970 to 2014].map (year, index) ->
  yearObj =
    year: year
    index: index
    deaths: 0
  incidentsByGroup = for i in [0 to 5]
    otherIncidentContainer =
      list: []
      deaths: 0
      isOther: yes
      year: yearObj
      group: groups[i]
    bigIncidents.push otherIncidentContainer
    combinedIncidentsAndContainers.push otherIncidentContainer
    list:[otherIncidentContainer]
    group: groups[i]
    otherIncidentContainer: otherIncidentContainer
  yearObj.incidentsByGroup = incidentsByGroup
  yearObj

for datum in data
  year = years[datum.year - 1970]
  datum.year = year
  year.deaths += datum.deaths
  if datum.deaths > 2 || datum.isCzech
    year.incidentsByGroup[datum.group.index].list.push datum
    bigIncidents.push datum
  else
    year.incidentsByGroup[datum.group.index].otherIncidentContainer.list.push datum
    year.incidentsByGroup[datum.group.index].otherIncidentContainer.deaths += datum.deaths
for year in years
  for group in year.incidentsByGroup
    group.list.sort (a, b) ->
      | a.isOther => 1
      | b.isOther => -1
      | otherwise => b.deaths - a.deaths

bigIncidents .= filter -> it.deaths
for incident, index in bigIncidents
  incident.id = index
map = new ig.Map container, data
barchart = new ig.Years container, years, bigIncidents, groupsAssoc
storyteller = new ig.Storyteller container
  ..on \story (groupName) ->
    if groupName
      if groupName == "Politický extrémismus"
        left = groupsAssoc['Extrémní levice']
        right = groupsAssoc['Extrémní pravice']
        for incident in combinedIncidentsAndContainers
          incident.downlight = !(incident.group == left || incident.group == right)
        for id, group of groupsAssoc
          group.yearSortIndex = group.index
        left.yearSortIndex = -2
        right.yearSortIndex = -1
        barchart
          ..resortYears!
          ..updateDownlighting!
      else if groupName == "Terorismus v Česku"
        for incident in combinedIncidentsAndContainers
          incident.downlight = !incident.isCzech
        for year in barchart.years
          previousDeaths = 0
          yearlyList = []
          for group in year.incidentsByGroup
            for incident in group.list
              if incident.isCzech
                yearlyList.unshift incident
              else
                yearlyList.push incident
          for incident in yearlyList
            incident.previousDeaths = previousDeaths
            previousDeaths += incident.deaths
        barchart
          ..repositionIncidents!
          ..updateDownlighting!
      else
        highlightedGroup = groupsAssoc[groupName]
        for incident in combinedIncidentsAndContainers
          incident.downlight = incident.group != highlightedGroup

        for id, group of groupsAssoc
          if group != highlightedGroup
            group.yearSortIndex = group.index
          else
            group.yearSortIndex = -1
        barchart
          ..resortYears!
          ..updateDownlighting!
    else
      barchart.cancelGroupHighlight!

    map.updateDownlighting!
incidentDisplayedInStoryteller = no
barchart.on \highlight (incident) ->
  map.drawHighlightCircles incident
  if incident.text
    incidentDisplayedInStoryteller := yes
    storyteller.showIncident incident
barchart.on \downlight (incident) ->
  map.unHighlight!
  if incidentDisplayedInStoryteller
    storyteller.hideIncident!
map.on \importantIncident (incident) ->
  storyteller.showIncident incident
map.on \importantIncidentOut (incident) ->
  storyteller.hideIncident!

body.append \div
  ..attr \id \top-menu-shade
new ig.Shares container
