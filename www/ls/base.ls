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
  if datum.deaths > 2
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
new ig.Years container, years, bigIncidents, groupsAssoc
new ig.Storyteller container
# console.log do
#   years
#     .map -> "#{it.year}\t#{it.deathsTotal}"
#     .join "\n"
