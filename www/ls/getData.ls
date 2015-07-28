groups =
  "Konflikt v Severním Irsku":
    name: "Konflikt v Severním Irsku"
    color: \#984ea3
    index: 0
  "Baskický separatismus":
    name: "Baskický separatismus"
    color: \#4daf4a
    index: 1
  "Arabský a islámský terorismus":
    name: "Arabský a islámský terorismus"
    color: \#377eb8
    index: 2
  "Extrémní levice":
    name: "Extrémní levice"
    color: \#e41a1c
    index: 3
  "Extrémní pravice":
    name: "Extrémní pravice"
    color: \#a65628
    index: 4
  "Ostatní":
    name: "Ostatní"
    color: \#999999
    index: 5
scale = d3.scale.linear!

for name, group of groups
  scale.range ['#000', group.color]
  group.darkColor = scale 0.85
  scale.range ['#fff', group.color]
  group.lightColor = scale 0.65

ig.getData = ->
  data = d3.tsv.parse ig.data.utoky, (row, index) ->
    for field, value of row
      continue if field is "group"
      continue if field is "text"
      continue if field is "link"
      row[field] = parseFloat value
    row.date = new Date!
      ..setTime 0
      ..setFullYear row.year
      ..setMonth row.month - 1
      ..setDate row.day
    row.group = groups[row.group]
    row.index = index
    row.isCzech = row.id in [12 314 717 719 871 932 1196]
    row

  {data, groups}
