turtles-own [
 game-time ; it could be 3 diffrent values:2 for harcore, 1 for midcore, and 0 for casual
 i-am-newbie ; if it is true, the agent starts to play after the 100 raid
 level; it defines the level of the agent
 is-interested ; it defines if the agent is interested in a loot
 raid-partecipation ; it defiens if the player has partecipate at a raid in a specific day

 dice ; it will used in some LS. It default vale is -1

 need-token ;It will used in dual token ls
 greed-token ;It will used in dual token ls

 dkp-points ;It defines the amount of points used for DKP LSs
 bonus-points ;It defines the amount of points used in Karma LSs

 dkp-offers ;It was used for Auction DKP LS

 dkp-gained ;It was used for DKP Relational LS
 dkp-spent ;It was used for DKP Relational LS
 dkp-ratio ;It was used for DKP Relational LS
]

globals [
 turtle-list
 use-newbie ;it become true after the "start-newbie-value"th mission. If it is equal to 1, it permits to partecipate at the newbies

 looter-list ; It will used in Pure List LS, Suicide Kings LS, etc.
 dkp-list ; It will used in DKP LSs. It is ordered using the ammount of dkp of each character

 average-hardcore-level
 average-midcore-level
 average-casual-level
 average-newbie-level
 average-level

]


to setup

  random-seed rndseed

  clear-all

  set average-hardcore-level 0
  set average-midcore-level 0
  set average-casual-level 0
  set average-newbie-level 0
  set average-level 0

  ;generate the initial ammout of players.
  ;percentageOfNewbie is a the value of newbies that start after the 100 mission
  create-players nplayers round (percentageOfNewbie * nplayers)

  set use-newbie false

  reset-ticks
end


to go


  reset-turtle
  ;Loop untile the max number of mission
  ifelse n-mission > ticks [
    if ticks > start-newbie-value [
      set-newbie
    ]
    let raid-players []
    set raid-players create-raid-team

    ;Extract the item
    let item-power 0
    set item-power (random 5 + 1)

    let looter -1
    set looter looting-system raid-players item-power
    get-the-item looter item-power
    perform-avarage-level


    tick
  ][
    show-results
    stop
  ]


end

;This method reset the temporary information of each turtle
to reset-turtle
  ask-concurrent turtles [
   set is-interested false
   set dice -1
   set raid-partecipation false
  ]
end

;This method perfom the average-level of each category of players
to perform-avarage-level
  set average-level mean [level] of turtles
  set average-hardcore-level mean [level] of turtles with [game-time = 2]
  set average-midcore-level mean [level] of turtles with [game-time = 1]
  set average-casual-level mean [level] of turtles with [game-time = 0]
  set average-newbie-level mean [level] of turtles with [i-am-newbie]
end

;This method print the results of the simulations
to show-results
  type "\n\n\n\n\n RESULTS: \n\n"
  type "average-hard-lvl " type average-hardcore-level type "\n"
  type "average-mid-lvl " type average-midcore-level type "\n"
  type "average-casual-lvl " type average-casual-level type "\n"
  type "average-newbie-lvl " type average-newbie-level type "\n"
  type "average-lvl " type average-level type "\n"
end

;This method defines the idem dropped in the raid
to get-the-item  [player item-power]

  let x 0
  set x ( ((random 40) + 1) * item-power)

  let mu 0
  set mu item-power * 20

  let sigma 5

  ask turtle player[
    ;p defines the probability to incremente the character's power
    let p 0
    set p normal-distribution x mu sigma
    ;let rndval random-float 1
    let rndval random 100
    set rndval rndval / 100

    ;===OUTPUT====
    output-type "Hi, I am " output-type player output-type ", I am a "
    if game-time = 2 [output-type "HARDCORE"]
    if game-time = 1 [output-type "MIDCORE"]
    if game-time = 0 [output-type "CASUAL"]
    output-type " player and I have the " output-type precision p 4
    output-type " probability to increase the level.... \n I have generate the number " output-type precision rndval 4
    output-type " so: \n "

    ifelse (p >= rndval)[
      set level level + x
      output-type "I INCREASE the level, my level now is: " output-type level
    ]
    [
      output-type "I have NOT increase the level, my level is: " output-type level
    ]
    output-type "\n======================================================\n"
  ]
end

;it select the current LS, and, consequentially, it returns the player that will loot the item
to-report looting-system [rplayer i-power]
  let looter 0
  ;each agent can add to the dice value its bonus
  ask-concurrent turtles with [raid-partecipation] [
    set bonus-points bonus-points + gain-points
    let dkp-gain gain-points
    set dkp-points dkp-points + dkp-gain
    set dkp-gained dkp-gained + dkp-gain
  ]

  define-interested-players
  order-dkp-list

  ifelse LootingSystem = "rolling" [set looter rolling]
  [ ifelse LootingSystem = "karma" [set looter karma]
    [ifelse LootingSystem = "pure-list" [set looter purelist]
      [ifelse LootingSystem = "suicide-kings" [set looter suicide-kings]
        [ifelse LootingSystem = "dkp-variable-price"[set looter dkp-var-price]
          [ifelse LootingSystem = "dkp-fix-price" [set looter dkp-fix i-power]
            [ifelse LootingSystem = "dkp-auction" [set looter dkp-auction i-power]
              [ifelse LootingSystem = "dkp-zero-sum" [set looter dkp-zero-sum]
                [ifelse LootingSystem = "dkp-relational" [set looter dkp-relational i-power]
                  [if LootingSystem = "dual-token" [set looter dual-token]
                  ]]]]]]]]]
  report looter
end

;This method order the DKP list
to order-dkp-list
  ;The list was ordered considering the amount of DKP of each agent
  set dkp-list []
  foreach sort-on  [( - dkp-points)] turtles [ [myturtle] -> ask myturtle [set dkp-list lput who dkp-list] ] ; the "-" is for sort in decrescent way
end

;Roll
to-report get-dice-roll
  report ((random dice-dimension) + 1)
end


;===========================================
;======= START LSs IMPLEMENTATION ==========
;===========================================

;Implementation of Rolling LS
to-report rolling
  ;Each player that partecipate to the raid and that has an interest in the item, roll a dice. The higher win the item
  ask-concurrent turtles with [is-interested and raid-partecipation][set dice (random 100 + 1)]
  report [who] of max-one-of turtles [dice]
end

;Implementation of Karma LS
to-report karma

  ;check between the interested agents who wants to use their bonus
  ask-concurrent turtles with [is-interested and raid-partecipation][
    set dice (random 100 + 1)
    if(is-loot-interested) [ set dice dice + bonus-points ]
  ]

  ;find the greater, remove its bonus points, and report it
  let w 0
  set w [who] of max-one-of turtles [dice]
  ask turtle w [ set bonus-points 0 ]
  report w

end

;Implementation of Pure List LS
to-report purelist
  report start-purelist 0
end

to-report start-purelist [startingPosition]
  ;scrolls the list generated in setup and assigns the object to the first one of the player that has partecipate at the raid. After that, place the agent last in the list

  ;Select the winner player and move it last position in the list
  let looter 0
  set looter item startingPosition looter-list
  set looter-list move-last looter looter-list

  ifelse ([raid-partecipation] of turtle looter)
  [
    ;It is not a member of the raid. Thus, we select the next in the list
    report start-purelist (startingPosition + 1)
  ]
  [
    ;It is an elegible players
    report looter
  ]
end

;Implementation of Suicide Kings LS
to-report suicide-kings
  ;scrolls the list generated in setup and assigns the object to the first one that want the item.
  ;After that, it places the agent last in the list

  foreach looter-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested] of turtle x
    [
      ;It is an elegible players
      ;Move it in the last position of the list and report it
      set looter-list move-last x looter-list
      report x
    ]
  ]
end

;Implementation of DKP Variable Price LS
to-report dkp-var-price
  ;It uses all the DKP of the interested players
  ;The system scolls the list, the first iterested receive the item

  foreach dkp-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested] of turtle x
    [
      ;It is an elegible players
      ;remove its DKPs and report it
      ask turtle x [set dkp-points 0]
      report x
    ]
  ]
end

;Implementation of DKP Fixed Price LS
to-report dkp-fix [i-power]
  ;Each item has a fixed price (10 times its power).
  ;If a player has enough DKP and it is insterest, it can buy it

  let price 0
  set price i-power * 5

  foreach dkp-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested and dkp-points >= price] of turtle x
    [
      ;It is an elegible players
      ;remove the price from its DKPs and report it
      ask turtle x [set dkp-points dkp-points - price]
      report x
    ]
  ]
end

;Implementation of DKP Auction LS
to-report dkp-auction [i-power]
  ;Each interested player offers a random ammount of dkp for the item (a random value between 2 to 4 times the value of the item)
  ;If an agent does not have enough dkp, it goes all in

  ask turtles with [raid-partecipation and is-interested][
    set dkp-offers ((random 3) + 2) * i-power
    if dkp-offers > dkp-points [set dkp-offers dkp-points]
  ]

  let winner 0
  set winner [who] of max-one-of turtles [dkp-offers]
  ask turtle winner [ set dkp-points dkp-points - dkp-offers]
  report winner
end

;Implementation of DKP Zero Sum LS
to-report dkp-zero-sum
  ;It does not follow any list. Thus, the system generate a new list
  ;When one user get the item, it splits its dkp with the others players of the team

  let temp-list []
  set temp-list shuffle looter-list

  foreach temp-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested] of turtle x
    [
      ;It is an elegible players
      ;It get the item and distribute its dkp to others raid members
      let dkp-temp 0
      set dkp-temp [dkp-points] of turtle x
      set dkp-temp ((dkp-temp / raid-dimension) - 1)
      ask turtle x [set raid-partecipation false]
      ask turtles with [raid-partecipation] [set dkp-points dkp-points + dkp-temp]
      ask turtle x [set raid-partecipation true]
      report x
    ]
  ]
end

;Implementation of DKP Relational
to-report dkp-relational [i-power]
  ;Each item has a fixed price (10 times its power).
  ;The interested player with the higher ration between dkp-gained and dkp-spent (and that has enough dkp) get the item

  let price 0
  set price i-power * 5

  ask turtles [set dkp-ratio -1]
  ask turtles with [raid-partecipation and is-interested and dkp-points >= price][
   set dkp-ratio  dkp-gained / dkp-spent
  ]
  let winner 0
  set winner [who] of max-one-of turtles [dkp-ratio]
  ask turtle winner [ set dkp-points dkp-points - price]
  report winner

end

;Implementation of Dual Token
to-report dual-token
  ;If the agent is insterested in a item and it is of the same class of the avatar (probability 1/4), it can use a need token
  ;otherwise, if nobody offers a need token, it can use a greed token
  ;if nobody offert both, the item was randomly assigned

  foreach looter-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested and need-token > 0] of turtle x
    [
      ;It is an elegible players check if it is of the same class of the object
      if random 4 = 0
      [
        ask turtle x [ set need-token need-token - 1 ]
        set looter-list move-last x looter-list
        report x
      ]
    ]
  ]

  ;If nobody uses the need token, it will use the greed token
  foreach looter-list[
    [x] ->

    ;Check if the player is interested and it is elegible
    if [raid-partecipation and is-interested and greed-token > 0] of turtle x
    [
      ;It is an elegible players
      ask turtle x [ set greed-token greed-token - 1 ]
      set looter-list move-last x looter-list
      report x
    ]
  ]

  ;if nobody uses the greed token, the system select a random one
  let winner 0
  set winner [who] of one-of turtles with [is-interested and raid-partecipation]
  set looter-list move-last winner looter-list
  report winner

end

;===========================================
;========= END LSs IMPLEMENTATION ==========
;===========================================

;This method work across the DKP and the Karma LSs. It return an amout of point according with the player behavior
to-report gain-points
  ; Poins that can be spend in karma or DKP LSs, they can be gained based on certain aspects as:
  let points 0

  ; puntuality
  if (random 100 < 90)[
    set points points + 5
  ]
  ; companion replacement
  if (random 100 < 20)[
    set points points + 5
  ]
  ; finish a raid
  if (random 100 < 90)[
    set points points + 5
  ]
  ; defeat a boss
  if (random 100 < 60)[
      set points points + 5
  ]

  report points

end

;This method defines the agents interested in a specific loot
to define-interested-players
  ask-concurrent turtles[
    set is-interested  is-loot-interested
  ]
end

;Move element in the last position in mylist
to-report move-last [element mylist]
 set mylist remove element mylist
 set mylist lput element mylist
 report mylist
end

;this method was called after the "start-newbie-value"th mission.
;it move the newbies in the last position in the list and
;allow newbie to partecipate at the raids
to set-newbie
  if use-newbie = false [
    ;;Move the newbie in the last position of the lists
    ask turtles with [i-am-newbie] [
      set looter-list move-last who looter-list
    ]
    ;allow the newbie to partecipate at the raids
    set use-newbie true
  ]
end

;This method return true if the player is interested in the loot, false otherwise
to-report is-loot-interested
  let val 0
  set val random 4
  ifelse val = 0 [report true][report false]
end

;This method selects 40 players to partecipate at the mission (in according with their features)
;It shuffle the player's list, flows it, and ask to each player if it can partecipate.
;When it reach 40 players, return the list of players
to-report create-raid-team

  let players []
  set players n-values raid-dimension [-1]

  let i 0
  let j 0
  while [i < raid-dimension][
    let shuf-turtle-list []
    set shuf-turtle-list shuffle turtle-list

    ask turtle item j shuf-turtle-list[
      ;;Check if it was elegible
      if ((i-am-newbie = false or use-newbie) and can-partecipate get-probability-to-partecipate game-time)[
        set players replace-item i players who

        set raid-partecipation true

        ;assign token for dual token ls
        set need-token need-token + 1
        set greed-token greed-token + 1

        set i i + 1
      ]
    ]

    set j j + 1
  ]

  report players
end

;It return true if the player was able to partecipate, false otherwise
to-report can-partecipate [prob]
  ;generate a random number between 1 - 100
  let p 0
  set p random 100
  set p p + 1

  ifelse p <= prob[
   report true
  ][
    report false
  ]
end

;This method return the probability (in percentage) to partecipate at a raid
;it take in input the type of game-time
to-report get-probability-to-partecipate [gt]
  ifelse gt = 0 [report 30]
  [ ifelse gt = 1 [report 60]
    [ifelse gt = 2 [report 90]
      [ report -1]
    ]
  ]
end

;It report the value of x in a normal distribution with mu as avarage and sigma as standard deviation
to-report normal-distribution [x mu sigma]
  report (e ^ ( -1 * (x - mu) ^ 2 / (2 * (sigma ^ 2))) / (sigma * sqrt(2 * pi)))
  ;report (e ^ ( -1 * (x - mu) ^ 2 / (2 * (sigma))) / (sqrt(sigma) * sqrt(2 * pi)))
end

;It generates the players, assigning to them their features
to create-players [p n]
  ;create the agents
  create-turtles p [setxy random-xcor random-ycor]

  let g-time-counter 0
  ;assign the time features
  ask turtles[
    ;it was assigned in a random way.
    ;as probabilistc significance, it distributes the population equally on the 3 different types
    set game-time g-time-counter
    set g-time-counter g-time-counter + 1
    if g-time-counter > 2 [ set g-time-counter 0]

    ;Set all the players as "expert"
    set i-am-newbie false

    ;Set the starting level for all player = 0
    set level 0

    ;Set the token value for dual token ls
    set need-token 0
    set greed-token 0

    ;Set the starting points
    set dkp-points random 30
    set bonus-points random 30

    set dkp-gained dkp-points
    set dkp-spent 0

    ;Set the raid partecipation of each player to false
    set raid-partecipation false
  ]

  ;;Generate a list of agents
  set turtle-list n-values p [ [i] -> i ]

  ;;Equally assigns to the firts n player the value of newbie
  foreach n-values n [[i] -> i][
    ask one-of turtles with [game-time = g-time-counter][
      set i-am-newbie true
      set g-time-counter g-time-counter + 1
      if g-time-counter > 2 [ set g-time-counter 0]
    ]

  ]

  ;Was defined the starting list for Pure List LS, Suicide Kings LS, etc..
  set looter-list shuffle turtle-list



end
@#$#@#$#@
GRAPHICS-WINDOW
895
31
1332
469
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
18
26
190
59
nplayers
nplayers
0
400
200.0
1
1
NIL
HORIZONTAL

BUTTON
420
44
483
77
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
496
48
559
81
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
19
142
191
175
n-mission
n-mission
10
500
240.0
1
1
NIL
HORIZONTAL

CHOOSER
214
18
362
63
LootingSystem
LootingSystem
"rolling" "karma" "pure-list" "suicide-kings" "dkp-variable-price" "dkp-fix-price" "dkp-auction" "dkp-zero-sum" "dkp-relational" "dual-token"
0

PLOT
974
231
1835
605
Increment Of Players Level
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Average-Population-Level" 1.0 0 -16777216 true "" "show average-level"
"Average-Harcore-Level" 1.0 0 -2674135 true "" "show average-hardcore-level"
"Average-Midcore-Level" 1.0 0 -955883 true "" "show average-midcore-level"
"Average-Casual-level" 1.0 0 -1184463 true "" "show average-casual-level"
"Average-Newbie-Level" 1.0 0 -13791810 true "" "show average-newbie-level"

BUTTON
620
101
692
134
goonce
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
19
72
191
105
percentageOfNewbie
percentageOfNewbie
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
19
182
191
215
start-newbie-value
start-newbie-value
0
n-mission
100.0
1
1
NIL
HORIZONTAL

SLIDER
212
78
384
111
dice-dimension
dice-dimension
3
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
201
144
373
177
raid-dimension
raid-dimension
10
100
40.0
1
1
NIL
HORIZONTAL

OUTPUT
58
286
837
659
11

SLIDER
430
155
602
188
rndseed
rndseed
1
2000
14.0
1
1
NIL
HORIZONTAL

INPUTBOX
443
196
598
256
rndseed
14.0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
