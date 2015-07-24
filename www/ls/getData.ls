groups =
  "Konflikt v Severním Irsku":
    name: "Konflikt v Severním Irsku"
    color: \#984ea3
    lightColor: \#ad68b7
    index: 1
  "Baskický separatismus":
    name: "Baskický separatismus"
    color: \#984ea3
    lightColor: \#ad68b7
    index: 2
  "Arabský a islámský terorismus":
    name: "Arabský a islámský terorismus"
    color: \#377eb8
    lightColor: \#5295cb
    index: 0
  "Ostatní":
    name: "Ostatní"
    color: \#999999
    lightColor: \#aaa
    index: 5
  "Extrémní levice":
    name: "Extrémní levice"
    color: \#e41a1c
    lightColor: \#e94042
    index: 3
  "Extrémní pravice":
    name: "Extrémní pravice"
    color: \#a65628
    lightColor: \#ce6c34
    index: 4
scale = d3.scale.linear!

for name, group of groups
  scale.range ['#ffffff', group.color]
  group.lightColor = scale 0.8

ig.getData = ->
  data = d3.tsv.parse ig.data.utoky, (row, index) ->
    for field, value of row
      continue if field is "group"
      row[field] = parseFloat value
    row.date = new Date!
      ..setTime 0
      ..setFullYear row.year
      ..setMonth row.month - 1
      ..setDate row.day
    row.group = groups[row.group]
    row.index = index
    row

  {data, groups}
