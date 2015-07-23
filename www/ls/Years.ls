radius = 4
margin = 1
class ig.Years
  (@parentElement, years, deaths, groupsAssoc) ->
    groups = for name, group of groupsAssoc
      group
    @element = @parentElement.append \div
      ..attr \class \years
      ..selectAll \div.year .data years .enter!append \div
        ..attr \class \year
        ..filter(-> 0 == it.year % 5)
          ..append \span
            ..attr \class \title
            ..html -> it.year
    @items = @element.selectAll \div.death .data deaths .enter!append \div
      ..attr \class (d) -> "death #{if 3 == d.yearIndex % 4 then 'last-col' else ''}"
      ..style \bottom (d, i) -> "#{5 * Math.floor d.yearIndex / 4 }px"
      ..style \left (d, i) -> "#{d.year.index * 21 +  5 * (d.yearIndex % 4)}px"
      ..style \background-color -> it.incident.group.color
      ..style \border-color (it, i) -> it.incident.group.lightColor
      ..on \mouseover @~highlightIncident
      ..on \touchstart @~highlightIncident

  highlightIncident: ({incident}) ->
    if @highlightedItems
      that.classed \active no
    @highlightedItems = @items
      .filter (-> it.incident is incident)
      .classed \active yes
