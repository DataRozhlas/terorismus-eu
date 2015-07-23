{data, groups} = ig.getData!
container = d3.select ig.containers.base

years = [1970 to 2014].map (year, index) ->
  deaths: []
  deathsTotal: 0
  year: year
  index: index

deaths = []
for datum in data
  year = years[datum.year - 1970]
  for death in [1 to datum.deaths]
    death =
      incident: datum
      year: year
    deaths.push death
    year.deaths.push death

for year in years
  year.deaths.sort (a, b) ->
    if a.incident.group.index - b.incident.group.index
      that
    else if a.incident.index - b.incident.index
      that
    else
      0
  for death, index in year.deaths
    death.yearIndex = index


new ig.Years container, years, deaths, groups

# console.log do
#   years
#     .map -> "#{it.year}\t#{it.deathsTotal}"
#     .join "\n"
