{data, groups} = ig.getData!
container = d3.select ig.containers.base

years = [1970 to 2014].map (year) ->
  deaths: []
  deathsTotal: 0
  year: year


for datum in data
  year = years[datum.year - 1970]
  for death in [1 to datum.deaths]
    death =
      incident: datum
    year.deaths.push death
  year.deaths.sort (a, b) -> a.incident.group.index - b.incident.group.index


new ig.Years container, years, groups

# console.log do
#   years
#     .map -> "#{it.year}\t#{it.deathsTotal}"
#     .join "\n"
