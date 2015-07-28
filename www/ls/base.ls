{data, groups: groupsAssoc} = ig.getData!
container = d3.select ig.containers.base
groups = []
for name, group of groupsAssoc
  groups[group.index] = group

bigIncidents = []

years = [1970 to 2014].map (year, index) ->
  yearObj =
    year: year
    index: index
  incidentsByGroup = for i in [0 to 5]
    otherIncidentContainer =
      list: []
      deaths: 0
      isOther: yes
      year: yearObj
      group: groups[i]
    bigIncidents.push otherIncidentContainer
    list:[otherIncidentContainer]
    group: groups[i]
    otherIncidentContainer: otherIncidentContainer
  yearObj.incidentsByGroup = incidentsByGroup
  yearObj

for datum in data
  year = years[datum.year - 1970]
  datum.year = year
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
# new ig.Map container, data
barchart = new ig.Years container, years, bigIncidents, groupsAssoc
storyteller = new ig.Storyteller container
  ..on \story (groupName) ->
    if groupName
      if groupName == "Politický extrémismus"
        left = groupsAssoc['Extrémní levice']
        right = groupsAssoc['Extrémní pravice']
        for incident in bigIncidents
          incident.downlight = !(incident.group == left || incident.group == right)
        for id, group of groupsAssoc
          group.yearSortIndex = group.index
        left.yearSortIndex = -2
        right.yearSortIndex = -1
        barchart
          ..resortYears!
          ..updateDownlighting!
      else if groupName == "Terorismus v Česku"
        for incident in bigIncidents
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
        barchart.highlightGroup groupName
    else
      barchart.cancelGroupHighlight!
    # console.log groupName


# console.log do
#   years
#     .map -> "#{it.year}\t#{it.deathsTotal}"
#     .join "\n"
