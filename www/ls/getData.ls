groups =
  separatisti:
    name: \separatisti
    color: \#984ea3
    lightColor: \#ad68b7
    index: 1
  islamisti:
    name: \islamisti
    color: \#377eb8
    lightColor: \#5295cb
    index: 0
  other:
    name: \other
    color: \#999999
    lightColor: \#aaa
    index: 5
  rudi:
    name: \rudi
    color: \#e41a1c
    lightColor: \#e94042
    index: 3
  hnedi:
    name: \hnedi
    color: \#a65628
    lightColor: \#ce6c34
    index: 4

groupsToCategories =
  "Irish Republican Army (IRA)"                           : \separatisti
  "Basque Fatherland and Freedom (ETA)"                   : \separatisti
  "Protestant Extremists"                                 : \separatisti
  "Ulster Volunteer Force (UVF)"                          : \separatisti
  "Ulster Freedom Fighters (UFF)"                         : \separatisti
  "Irish National Liberation Army (INLA)"                 : \separatisti
  "Irish Republican Extremists"                           : \separatisti
  "First of October Antifascist Resistance Group (GRAPO)" : \rudi
  "Red Brigades"                                          : \rudi
  "Official Irish Republican Army (OIRA)"                 : \separatisti
  "Neo-Nazi Group"                                        : \hnedi
  "November 17 Revolutionary Organization (N17RO)"        : \rudi
  "Irish People's Liberation Organization (IPLO)"         : \separatisti
  "Anti-terrorist Liberation Group (GAL)"                 : \separatisti
  "Prima Linea"                                           : \rudi
  "Corsican National Liberation Front (FLNC)"             : \separatisti
  "Red Army Faction (RAF)"                                : \rudi
  "Loyalist Volunteer Forces (LVF)"                       : \separatisti
  "Armed Revolutionary Nuclei (NAR)"                      : \hnedi
  "Italian Social Movement (MSI)"                         : \hnedi
  "Red Hand Commandos"                                    : \separatisti
  "Red Hand Defenders (RHD)"                              : \separatisti
  "Real Irish Republican Army (RIRA)": \separatisti
  "Republican Action Force": \separatisti
  "Hizballah"                                                                     : \islamisti
  "Qaddaffis"                                                                     : \islamisti
  "Secret Organization of al-Qa’ida in Europe"                                    : \islamisti
  "Iranians"                                                                      : \islamisti
  "Palestinians"                                                                  : \islamisti
  "Lebanese Armed Revolutionary Faction (LARF)"                                   : \islamisti
  "Committee of Solidarity with Arab and Middle East Political Prisoners (CSPPA)" : \islamisti
  "Popular Front for the Liberation of Palestine, Gen Cmd (PFLP-GC)"              : \islamisti
  "Popular Front for the Liberation of Palestine (PFLP)": \islamisti
  "May 15 Organization for the Liberation of Palestine"                           : \islamisti
  "Armed Islamic Group (GIA)"                                                     : \islamisti
  "Palestine Liberation Organization (PLO)"                                       : \islamisti
  "Abu Hafs al-Masri Brigades": \islamisti
  "Serbian Militants": \separatisti
  "Black September": \islamisti
  "Kosovo Liberation Army (KLA)": \separatisti
  "Croatian Militia": \separatisti
  "Serbian guerrillas": \separatisti
  "Armenian Secret Army for the Liberation of Armenia": \separatisti
  "Justice Commandos for the Armenian Genocide": \separatisti


ig.getData = ->
  data = d3.tsv.parse ig.data.utoky, (row, index) ->
    for field, value of row
      continue if field is "name"
      row[field] = parseFloat value
    row.date = new Date!
      ..setTime 0
      ..setFullYear row.year
      ..setMonth row.month - 1
      ..setDate row.day
    row.category = groupsToCategories[row.name] || "other"
    row.group = groups[row.category]
    row.index = index
    row
  {data, groups}
