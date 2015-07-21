radius = 4
margin = 1
class ig.Years
  (@parentElement, data, groupsAssoc) ->
    groups = for name, group of groupsAssoc
      group
    @parentElement.append \div
      ..attr \class \years
      ..selectAll \div.year .data data .enter!append \div
        ..attr \class \year
        ..selectAll \div.item .data (-> it.deaths) .enter!append \div
          ..attr \class \death
          ..style \bottom (d, i) -> "#{5 * Math.floor i / 4 }px"
          ..style \left (d, i) -> "#{5 * (i % 4)}px"
          ..style \background-color -> it.incident.group.color
          ..style \border-color -> it.incident.group.lightColor
