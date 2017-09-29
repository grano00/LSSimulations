;Agents features
turtles-own [
  bartle-type ;;It defines the bartle type: 65=achiever,45=explorer,105=socializer,15=killer
  turtle-team ;; list with the group of player that partecipate at the team
  iwin ;; 1 = win the match, 0 = loss the match, -1 = do not partecipate at the match
  game-time  ;;1=casual 2=min 3=hardcore
  personal-friend-list ;;list with friends. It have defined a max length
  win-prob;

  chest-quantity ;;number of available chest
  key-quantity ;;number of available key
  key-fragment-quantity ;;number of available key fragment
  days-do-not-win ;; days passed since the last victory
  how-many-keys ;; keys obtained since the first key (each 30 days, they will be reset)
  how-many-characters ;; number of champion unlocked by the player
  day-from-first-key ;;it is a support of the key reset after 30 days
  my-tick ;; it is used in order to define the days for the key drop
  day-from-last-drop ;; it will be usefull for define the un-satisfaction
  drop-something ;; self-explanatory

  match-valutation ;; 0 = a generic result, 1 = a value better then S- , 2 = the player gain a S- but it cannot take a chest

  ;; these variables are counters TODO,check if i use them all
  number-normal-char
  number-mid-char
  number-strong-char
  number-frag-char

  number-normal-skin
  number-mid-skin
  number-ulti-skin
  number-frag-skin

  ;; these are lists. The name are self-explanatory. fig means that it is a list of fragment of items (i named them figure) i.e. these fig need a ammount of number-frag-* in order to unlock a real item
  favorite-character-list
  obtained-char-figure-list
  obtained-char-list
  char-obtain-chest  ;; champions that obtain a chest. This value will be reset each 365 days

  obtained-ulti-skin-list
  obtained-mid-skin-list
  obtained-norm-skin-list
  obtained-ulti-fig-skin-list
  obtained-mid-fig-skin-list
  obtained-norm-fig-skin-list

  obtained-ward
  interessed-ward
  obtained-icons
  interessed-icons

  ;; these informations are about the char in use each match. If char-in-use is equal to -1, it means that the player do not receive a S and it cannot get a chest
  index-char-in-use
  char-in-use

  ;; must be implemented, it define the satisfaction of each player
  satisfaction

  chest-busy-slot;




]

globals [
  approximation ;; is a general value of approximation used for the input variable
  turtle-list ;; a list of each agent
  team-list ;;a list of teams
  team-players-list ;; have to be a set of list inside a list (a matrix)
  players-able-to-play ;; the player avalible to get in match
  team-number
  winning-list ;; a list that define if a team win (0 if it lose and 1 if it win)
  team-player-matrix ;; it is a list of list. each sub list define a team
  character-list
  ulti-skin-by-char-list ;List that contains (for each skin) the number of ultimate skins
  mid-skin-by-char-list ;List that contains (for each skin) the number of medium skins
  norm-skin-by-char-list ;List that contains (for each skin) the number of normal skins
  total-skin-number

  ;These are values in order to define the satisfaction
  avarage-satisfaction

  avarage-hardcore
  avarage-midcore
  avarage-casual

  avarage-archiever
  avarage-explorer
  avarage-killer
  avarage-socializer

  avarage-casual-archiever
  avarage-casual-explorer
  avarage-casual-killer
  avarage-casual-socializer

  avarage-midcore-archiever
  avarage-midcore-explorer
  avarage-midcore-killer
  avarage-midcore-socializer

  avarage-hardcore-archiever
  avarage-hardcore-explorer
  avarage-hardcore-killer
  avarage-hardcore-socializer

  casual
  mid
  hardcore

]

to setup
  clear-all
  set approximation 1000000000000 ;;This is the value of approximation for the float numbers
  set team-number 0
  if my-random-seed = false [  random-seed my-seed ] ;; check if enable the seed in order to repeat the experiment
  ifelse check-data ;; if the input data are correct enable the software
  [
     generate-players ;;create the agents
     define-agents-types ;;define the starting agents features
     set-turtle-list ;;create a list wit all agents and shuffle it
     modify-turtle-to-follow ;;get a particular ;) design and features at the following turtle
     create-a-team ;; set teams (this can be delete in setup phase, stay here for debug reasons)
     ask turtles [set obtained-char-list order-list obtained-char-list favorite-character-list] ;; reorder the characters with favorite order
     reset-ticks
   ]
  [
    reset-ticks
  ]
end



to go

  ifelse number-of-days > ticks or defined-number-of-days = false [
    ;sunrise
    foreach range (( random 1 ) + 3 )[ ;;design the number of match by day

      reset-turtles ;Reset the turtle parameters

      create-a-team ;It create the teams
      reorder-for-friends ;; set the friend near in the list
      create-team-matrix ;; define the teams splitting the list in five and create a list of list
      define-winning-team ;; define the winning team
      distribute-winning-among-players ;; define the winning user
      distribute-friends ;; try to add friends in the player list
      drop-key-fragment ;; check if the player get a key
      check-for-s-value ;; distribute the valutation among the players
      distribute-chest ;; check if a player gain a chest
      can-open-a-chest ;; check if a player is able to open a check

      ;reorder the obtained object in the favorite list order
      ask turtles [set obtained-char-figure-list order-list obtained-char-figure-list favorite-character-list]

      ;if it is possibile, it try to unlock the characters and the skins
      check-permanent-farag-trasf

      ;reorder the unlocked objects in the favorite list order
      ask turtles [set obtained-char-list order-list obtained-char-list favorite-character-list]

      print "\n---\n"
    ]
    print "#####"
    perform-avarage-satisfaction
    check-without-drop ;;Check the days without drop in order to modify the sadisfaction
    key-and-chest-days-reset ;;Check if the key/chest statistcs should be reset
    ask turtle turtle-to-follow [type "sadisfaction at day " type ticks type " is " type satisfaction type "\n"]


  tick ;;sunset
  ] [ stop ]
end

to check-without-drop
  ask turtles[
    if drop-something = false [
      let sat 0
      set sat satisfaction
      define-unsatisfaction who day-from-last-drop unsat-multiplier
      if who = turtle-to-follow [type "satisfaction drop down of " type (satisfaction - sat) type ". Before satisfaction was " type sat type ", now " type satisfaction type "\n day-from-last-drop = " type day-from-last-drop type "\n"]
      set day-from-last-drop day-from-last-drop + 1
    ]
  ]
end


;;This method calculate the avarage satisfaction on the agents
to perform-avarage-satisfaction
  set avarage-satisfaction mean [satisfaction] of turtles
  let tot []

  set tot [satisfaction] of turtles with [game-time = p-hardcore * 100]
  if length tot != 0 [set avarage-hardcore mean tot]
  set tot [satisfaction] of turtles with [game-time = p-mid * 100]
  if length tot != 0 [set avarage-midcore mean tot]
  set tot [satisfaction] of turtles with [game-time = p-casual * 100]
  if length tot != 0 [set avarage-casual mean tot]

  set tot [satisfaction] of turtles with [bartle-type = 65]
  if length tot != 0 [set avarage-archiever mean tot]
  set tot [satisfaction] of turtles with [bartle-type = 45]
  if length tot != 0 [set avarage-explorer mean tot]
  set tot [satisfaction] of turtles with [bartle-type = 15]
  if length tot != 0 [set avarage-killer mean tot]
  set tot [satisfaction] of turtles with [bartle-type = 105]
  if length tot != 0 [set avarage-socializer mean tot]

  set tot [satisfaction] of turtles with [game-time = p-casual * 100 and bartle-type = 65]
  if length tot != 0 [set avarage-casual-archiever mean tot]
  set tot [satisfaction] of turtles with [game-time = p-casual * 100 and bartle-type = 45]
  if length tot != 0 [set avarage-casual-explorer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-casual * 100 and bartle-type = 15]
  if length tot != 0 [set avarage-casual-killer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-casual * 100 and bartle-type = 105]
  if length tot != 0 [set avarage-casual-socializer mean tot]


  set tot [satisfaction] of turtles with [game-time = p-mid * 100 and bartle-type = 65]
  if length tot != 0 [set avarage-midcore-archiever mean tot]
  set tot [satisfaction] of turtles with [game-time = p-mid * 100 and bartle-type = 45]
  if length tot != 0 [set avarage-midcore-explorer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-mid * 100 and bartle-type = 15]
  if length tot != 0 [set avarage-midcore-killer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-mid * 100 and bartle-type = 105]
  if length tot != 0 [set avarage-midcore-socializer mean tot]

  set tot [satisfaction] of turtles with [game-time = p-hardcore * 100 and bartle-type = 65]
  if length tot != 0 [set avarage-hardcore-archiever mean tot]
  set tot [satisfaction] of turtles with [game-time = p-hardcore * 100 and bartle-type = 45]
  if length tot != 0 [set avarage-hardcore-explorer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-hardcore * 100 and bartle-type = 15]
  if length tot != 0 [set avarage-hardcore-killer mean tot]
  set tot [satisfaction] of turtles with [game-time = p-hardcore * 100 and bartle-type = 105]
  if length tot != 0 [set avarage-hardcore-socializer mean tot]


end

;This method order the element of myList1 according to myList2
to-report order-list[myList1 myList2]
  let temp-list[]
  foreach myList1[[x]-> set temp-list lput position x myList2 temp-list]
  set myList1 []
  set temp-list sort temp-list
  foreach temp-list[[x]-> set myList1 lput item x myList2 myList1]
  report myList1
end

;Check if an agent can open a chest.
to can-open-a-chest
  ask turtles[
      ;If the agent has the items to open a chest
      if  chest-quantity > 0 and key-quantity > 0
      [
        set chest-quantity chest-quantity - 1
        set key-quantity key-quantity - 1

        let chest-drop 0
        ;Generate a random number between 0 and the summed value of the items probability
        set chest-drop random 10368

        ;Check what item the player has unlocked
        if chest-drop < 3144 [ get-champ(who) ] ;champ
        if chest-drop >= 3144 and chest-drop < 3144 + 6040 [get-skin(who)] ;skin
        if chest-drop >= 3144 + 6040 and chest-drop < 3144 + 6040 + 530 [get-ward(who)] ; lumi
        if chest-drop >= 3144 + 6040 + 530 and chest-drop < 3144 + 6040 + 530 + 286 [get-icon(who)] ; icons
        if chest-drop >= 3144 + 6040 + 530 + 286 and chest-drop < 3144 + 6040 + 530 + 286 + 368 [get-gem(who)] ; gems

      ]
  ]
end


;Check if the player can permanent unlock a character and/or a skin
to check-permanent-farag-trasf

   ask turtles [

    let char-unlocked 0
    set char-unlocked unlock-character who

    let skin-unlocked 0
    set skin-unlocked unlock-skin who
  ]

end

;; This method defines the satisfaction when a agent unlock an item (character/skin)
to define-sadisfaction [agent pointer max-pointer multiplier]
  ;; Here i define the satisfaction in according with the following equation:
  ;; S(N) = ((F(N)+ max(|F(N)|)/max(|F(N)|)) * 100 => where F(N) = (-N^2+N) and N is the legnth of character and n_i is pointer+1
  ;; in addition if N_i >= round ( n*2/3) => F(N) -> F(n*2/3)

ask turtle agent [
  set pointer pointer + 1
  let f 0
  let f-max 0
  let s 0
  set f-max (((max-pointer * max-pointer ) * -1 ) + max-pointer) * -1 ;; (it is always a negative value)

  if pointer >= round ( max-pointer * (2 / 3) ) [ set pointer round ( max-pointer * (2 / 3)) ]

  set f ((pointer * pointer ) * -1 ) + pointer
  set s (( f + f-max ) / f-max ) * multiplier

  set satisfaction satisfaction + bartle-value-modifer s
  if who = turtle-to-follow [type "satisfaction increment of " type s type " before was " type (satisfaction - s) type " now is " type satisfaction type "\n"]

]

end


;It define the unsatisfaction when an agent does not unlock anything.
;We use, in the simulation, an exponential function (that pass between two point revealed by a survey)
;uncomment the other part of code in order to use different kind of functions
to define-unsatisfaction [ agent pointer multiplier ]
  ask turtle agent [
    let d 0
    let y1 0.579487179
    let y2 0.651282051

    ;Linear function
    ;set d (1 / 6) * (y1 * ((-1) * pointer) + (7 * y1) + (pointer * y2) - y2)


    ;exponential function (y=ae^(bx))
    set y1 y1 * 10
    set y2 y2 * 10
    let a 0.0
    let b 0.0

    set a (y1 ^ (7 / 6)) / (y2 ^ (1 / 6))
    set b ln(y1) - ln(a)
    set d (a * ( e ^ ( b * pointer )))

    ;hyperbole function
    ;let cof1 0.1
    ;let cof2 0.1
    ;set cof1  6 / (7 * (a ^ 2) - (b ^ 2))
    ;set cof2 ((b ^ 2) - (a ^ 2)) / ((7 * ( a ^ 2)) - (b ^ 2))
    ;if cof1 = 0 [ set cof1 0.01 ]
    ;set d (-1) * ((sqrt((cof2 * (pointer ^ 2)) - 1)) / (sqrt(cof1)))


    set satisfaction satisfaction - bartle-value-modifer ( d )
  ]
end


;;This method unlocks the agents skins
to-report unlock-skin [agent]

  let char 0
  ask turtle agent [
    ;;loop an i on favorite character list, at the first time that i meets a skin (priority ulti, mid, norm) check if it can unlock the skin. if it is true, unlock end exit from the loop, else continue with the next one
    let i 0

    while [ i < length favorite-character-list ]
    [

       set char item i favorite-character-list

       ;Unlock an ulti skin
       if item char obtained-ulti-fig-skin-list > 0 and number-frag-skin >= 9 and position char obtained-char-list != false
       [
          set obtained-ulti-skin-list replace-item char obtained-ulti-skin-list ( ( item char obtained-ulti-skin-list ) + 1 )
          set obtained-ulti-fig-skin-list replace-item char obtained-ulti-fig-skin-list ( ( item char obtained-ulti-fig-skin-list ) - 1 )
          if who = turtle-to-follow [type "ulti skin ulock: "]
          define-sadisfaction who i length favorite-character-list ulti-skin-multiplier
          set i length favorite-character-list
       ]

       ;Unlock a middling skin
       if item char obtained-mid-fig-skin-list > 0 and number-frag-skin >= 6 and i < length favorite-character-list and position char obtained-char-list != false
       [
          set obtained-mid-skin-list replace-item char obtained-mid-skin-list ( ( item char obtained-mid-skin-list ) + 1 )
          set obtained-mid-fig-skin-list replace-item char obtained-mid-fig-skin-list ( ( item char obtained-mid-fig-skin-list ) - 1 )
          if who = turtle-to-follow [type "mid skin ulock: "]
          define-sadisfaction who i length favorite-character-list mid-skin-multiplier
          set i length favorite-character-list
       ]

       ;Unlock a normal skin
       if item char obtained-norm-fig-skin-list > 0 and number-frag-skin >= 3 and i < length favorite-character-list and position char obtained-char-list != false
       [
          set obtained-norm-skin-list replace-item char obtained-norm-skin-list ( ( item char obtained-norm-skin-list ) + 1 )
          set obtained-norm-fig-skin-list replace-item char obtained-norm-fig-skin-list ( ( item char obtained-norm-fig-skin-list ) - 1 )
          if who = turtle-to-follow [type "norm skin ulock: "]
          define-sadisfaction who i length favorite-character-list norm-skin-multiplier
          set i length favorite-character-list
       ]

       set i i + 1
    ]

  ]
  report char
end


;This method unlock a character according with the agent favorite list
to-report unlock-character[agent]

  let my-agent 99999999
  set my-agent item ( length favorite-character-list - 1 ) favorite-character-list
  let agent-cost 0
  let ag-pos 999999999
  let ag-type -1 ; 0 norm 1 mid 2 strong
  ask turtle agent[
    let i 0
    while [i < length obtained-char-figure-list] [
      let x 0
      set x item i obtained-char-figure-list

       if position x obtained-char-list = false  [

       if x < (length character-list) * 0.29 and number-frag-char >= 3
         [ ;Unlock a normal
           set my-agent x
           set agent-cost 3
           set ag-type 0
           set i length obtained-char-figure-list
           if who = turtle-to-follow [type "char ulock: "]
           define-sadisfaction who position x favorite-character-list length favorite-character-list char-multiplier
         ]
         if x >= (length character-list) * 0.29 and x < (length character-list) * (0.29 + 0.49) and number-frag-char >= 6
         [ ;Unlock a middling
           set my-agent x
           set agent-cost 6
           set ag-type 1
                      if who = turtle-to-follow [type "char ulock: "]
           define-sadisfaction who position x favorite-character-list length favorite-character-list char-multiplier
         ]
         if x >=  (length character-list) * (0.29 + 0.49) and number-frag-char >= 9
         [;Unlock a strong
           set my-agent x
           set agent-cost 9
           set ag-type 2
           set i length obtained-char-figure-list
                      if who = turtle-to-follow [type "char ulock: "]
           define-sadisfaction who position x favorite-character-list length favorite-character-list char-multiplier
         ]

       ]
       set i i + 1
    ]

    ;;IF it is different to -1, it means that the agent unlock something. Thus, the enviroment modify its paramenters
    ifelse ag-type != -1 [
      set how-many-characters how-many-characters + 1
      if ag-type = 0 [set number-normal-char number-normal-char - 1]
      if ag-type = 1 [set number-mid-char number-mid-char - 1]
      set number-frag-char number-frag-char - agent-cost
      set obtained-char-figure-list remove my-agent obtained-char-figure-list
      set obtained-char-list lput my-agent obtained-char-list
    ]
    [
      set my-agent -1
    ]

    ;If the agent is the turtle-to-follow, it displays the information in debug
    if agent = turtle-to-follow [type "it unlock " type my-agent type "\n"]

  ]


   report my-agent
end


;This method defines the probability to get a champion fragment from a chest
;If the fragment are not consider an interessing item, it will be destroyed to get fragments
to get-champ [agent]

  ask turtle agent [
     let prob 0
     set prob random length character-list

     ;The s paramenter below (hard-coded) is revealed by the survey
     if prob < (length character-list) * 0.29  [
       ;It get a normal champion fragment
       ifelse position prob obtained-char-list != false and position prob obtained-char-figure-list != false and random length character-list - length  obtained-char-figure-list - length obtained-char-list > ( length character-list - length  obtained-char-figure-list - length obtained-char-list -  position prob favorite-character-list ) * 0.5
       [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a normal char"]
        set number-normal-char number-normal-char + 1
        set obtained-char-figure-list lput prob obtained-char-figure-list
        let s 2.13

        set satisfaction satisfaction + bartle-value-modifer s
      ]
      [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a normal char and destroy it"]
        set number-frag-char number-frag-char + 1
        let s 0.71
        set satisfaction satisfaction + bartle-value-modifer s
      ]
    ]

    if prob >= (length character-list) * 0.29 and prob < (length character-list) * ( 0.29 + 0.49 )   [
      ;It get a middling champion fragment
      ifelse position prob obtained-char-list != false and position prob obtained-char-figure-list != false and random length character-list - length  obtained-char-figure-list - length obtained-char-list > ( length character-list - length  obtained-char-figure-list - length obtained-char-list -  position prob favorite-character-list ) * 0.5
      [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a mid char"]
         set number-mid-char number-mid-char + 1
         set obtained-char-figure-list lput prob obtained-char-figure-list
         let s 4.26

         set satisfaction satisfaction + bartle-value-modifer s
      ]
      [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a mid char and destroy it"]
         set number-frag-char number-frag-char + 2
         let s 0.71
         set satisfaction satisfaction + bartle-value-modifer s
      ]
    ]

    if prob >= (length character-list) * ( 0.29 + 0.49 ) [
      ;It get a strong champion fragment
      ifelse position prob obtained-char-list != false and position prob obtained-char-figure-list != false and random length character-list - length  obtained-char-figure-list - length obtained-char-list > ( length character-list - length  obtained-char-figure-list - length obtained-char-list -  position prob favorite-character-list ) * 0.5
        [
         if agent = turtle-to-follow [output-print "turtle-to-follow gain a strong char"]
         set number-strong-char number-strong-char + 1
         set obtained-char-figure-list lput prob obtained-char-figure-list
         let s 8.51

         set satisfaction satisfaction + bartle-value-modifer s
       ]
       [
         if agent = turtle-to-follow [output-print "turtle-to-follow gain a strong char and destroy it"]
         set number-frag-char number-frag-char + 3
         let s 0.71
         set satisfaction satisfaction + bartle-value-modifer s
       ]
    ]
  ]
end


;This method defines the probability to get a skin fragment from a chest
;If the fragment are not consider an interessing item, it will be destroyed to get fragments
to get-skin [agent]

  ask turtle agent [

     let prob 0
     set prob random total-skin-number

     ;The s paramenter below (hard coded) is revealed by the survey
     if prob < sum norm-skin-by-char-list [
       let char-skin -1
       let controller 0

     ;; Check if the skin exists in the list and get the first skin that correspond
       while [controller = 0] [
         set char-skin random length norm-skin-by-char-list
         if item char-skin norm-skin-by-char-list != 0 [ set controller -1 ]
      ]
     let what-skin 0
     set what-skin item char-skin norm-skin-by-char-list
     let user-skin 0
     set user-skin ( ( item char-skin obtained-norm-fig-skin-list ) + ( item char-skin obtained-norm-skin-list ))

     ;; the probability to maintain a skin is ((a - b) / a ) * 100 / a  (in %) where a is the max number of skins and b is the number of player's skins
     ;; the second condition defines the position of the character in favorite list and boost the first one. 1.005 help a little bit the possibity that the agent maintend the figure


      ifelse random-float 100 < (((what-skin - user-skin ) / what-skin ) * ( 100 / what-skin)) and random-float 100 < (100 - ( position char-skin favorite-character-list / length character-list ) * 100 ) * 1.005 [
        ;get a normal skin
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a normal skin"]
        set obtained-norm-fig-skin-list replace-item char-skin obtained-norm-fig-skin-list (item char-skin obtained-norm-fig-skin-list + 1)
        set number-normal-skin number-normal-skin + 1
        let s 4.06

        set satisfaction satisfaction + bartle-value-modifer s
      ]
      [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a normal skin and destroy it"]
        set number-frag-skin number-frag-skin + 1
        let s 1.35
         set satisfaction satisfaction + bartle-value-modifer s
      ]
    ]

    if prob >= sum norm-skin-by-char-list and prob < sum norm-skin-by-char-list + sum mid-skin-by-char-list   [

      let char-skin -1
      let controller 0
      while [controller = 0] [
         set char-skin random length mid-skin-by-char-list
         if item char-skin mid-skin-by-char-list != 0 [ set controller -1 ]
      ]

     let what-skin 0
     set what-skin item char-skin mid-skin-by-char-list
     let user-skin 0
     set user-skin ( ( item char-skin obtained-mid-fig-skin-list ) + ( item char-skin obtained-mid-skin-list ))


      ifelse random-float 100 < (((what-skin - user-skin ) / what-skin ) * ( 100 / what-skin)) and random-float 100 < (100 - ( position char-skin favorite-character-list / length character-list ) * 100 ) * 1.005
      [
        ;get a middling skin
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a mid skin"]
        set obtained-mid-fig-skin-list replace-item char-skin obtained-mid-fig-skin-list (item char-skin obtained-mid-fig-skin-list + 1)
        set number-mid-skin number-mid-skin + 1
        let s 8.13

        set satisfaction satisfaction + bartle-value-modifer s
      ]
      [
        if agent = turtle-to-follow [output-print "turtle-to-follow gain a mid skin and destroy it"]
         set number-frag-skin number-frag-skin + 2
         let s 1.35
         set satisfaction satisfaction + bartle-value-modifer s
      ]
    ]

    if prob >= sum norm-skin-by-char-list + sum mid-skin-by-char-list    [
      let char-skin -1
      let controller 0
      while [controller = 0] [
         set char-skin random length ulti-skin-by-char-list
         if item char-skin ulti-skin-by-char-list != 0 [ set controller  -1 ]
      ]

     let what-skin 0
     set what-skin item char-skin ulti-skin-by-char-list
     let user-skin 0
     set user-skin ( ( item char-skin obtained-ulti-fig-skin-list ) + ( item char-skin obtained-ulti-skin-list ))


      ifelse random-float 100 < (((what-skin - user-skin ) / what-skin ) * ( 100 / what-skin)) and random-float 100 < (100 - ( position char-skin favorite-character-list / length character-list ) * 100 ) * 1.005[
         ;get a strong skin
         if agent = turtle-to-follow [output-print "turtle-to-follow gain a strong skin"]
         set obtained-ulti-fig-skin-list replace-item char-skin obtained-ulti-fig-skin-list (item char-skin obtained-ulti-fig-skin-list + 1)
         set number-ulti-skin number-ulti-skin + 1
         let s 16.26
         set satisfaction satisfaction + bartle-value-modifer s
       ]
       [
         if agent = turtle-to-follow [output-print "turtle-to-follow gain a strong skin and destroy it"]
         set number-frag-skin number-frag-skin + 3
         let s 1.35
         set satisfaction satisfaction + bartle-value-modifer s

       ]
    ]

  ]


end

;This method unlocks the ward using a chest
to get-ward [agent]
  ask turtle agent [
    if sum obtained-ward != length obtained-ward [
      if who = turtle-to-follow [type "ulock ward, up to  " type ward-value type "\n"]
      let rand random length obtained-ward
      while [item rand obtained-ward != 0][
        set rand random length obtained-ward
      ]

      ;It defines the satisfaction according with the favorite ward defined in setup phase
      ifelse item rand interessed-ward = 1 [set satisfaction satisfaction + bartle-value-modifer ward-value][set satisfaction satisfaction + ( bartle-value-modifer ward-value / 2)]

    ]
  ]
end

;This method unlocks the ward using a chest
to get-icon [agent]
  ask turtle agent[
   if sum obtained-icons != length obtained-icons [
      if who = turtle-to-follow [type "ulock icon, up to  " type icons-value type "\n"]
      let rand random length obtained-icons
      while [item rand obtained-icons != 0][
        set rand random length obtained-icons
      ]

      ;It defines the satisfaction according with the favorite ward defined in setup phase
      ifelse item rand interessed-icons = 1 [set satisfaction satisfaction + bartle-value-modifer icons-value][set satisfaction satisfaction + (bartle-value-modifer icons-value / 2)]

    ]
  ]
end

;This method unlocks a gem using a chest
to get-gem [agent]
  ask turtle agent[
    if who = turtle-to-follow [type "ulock gem, up to  " type gem-value type "\n"]
    set satisfaction satisfaction + bartle-value-modifer gem-value
  ]
end


;Check if a agent obtain a match evaluation equal to S
to check-for-s-value

  ask turtles [
    if who = turtle-to-follow [print "turtle to follow check for s value"]

    ;The probability to gain a rage equal to S will be decreased if the player lost the match
    let prob 0
    set prob s-probability * approximation
    if iwin = 0 [set prob prob * 0.7]
    let rand-value 0
    set rand-value random approximation

    set-char-in-use who

    ifelse rand-value <= prob [
      set match-valutation 1

      if char-in-use = -1 [
        set match-valutation 2
      ]
    ][
      set match-valutation 0
    ]
    if index-char-in-use = -1[
       set index-char-in-use random length obtained-char-list ;;this defines tha position of the character in use, anyway maintain the variable char-in-use = -1 in order to know that the player end tha available char
    ]
   if who = turtle-to-follow [type "it char in use is " type char-in-use type ", the rand-value <= prob  is " type rand-value <= prob type " and it match valutation is " type match-valutation type "\n"]
  ]
end


;This method defines the character used by the summoner (agent) in the match.
;This information will used in order to understand the probability to get a chest
;The agent behavior is desined to use (if possible) a caracter able to gain a loot
to set-char-in-use[agent]

  ask turtle agent[
    let find false
    let i 0
    while [i < length obtained-char-list and find = false][
      let x 0
      set x item i obtained-char-list
      if position x char-obtain-chest = false [
        set char-in-use x
        set index-char-in-use position char-in-use obtained-char-list
        set find true
      ]
      set i i + 1
    ]

    if find = false[
      set char-in-use -1
      set index-char-in-use -1
    ]
  ]

end

;This method analyze the match results and calculate the probability to assign a chest at the agents
to distribute-chest
  ask turtles [

    ;;in order to help computational calculation, I use an ifelse
    ifelse match-valutation = 1 [ get-chest who item index-char-in-use obtained-char-list ]
    [
      let friend-in-team  []
      set friend-in-team check-friends-in-team-of who
      let character-with-s-value []
      if who = turtle-to-follow [type "friend in team are " type friend-in-team type ", their valutation-char are "]
      ;;get the character of friend that win a match with s value
      foreach friend-in-team
      [
        [x]->
        let match-val 0
        set match-val [match-valutation] of turtle x
          if match-val > 1 [
            set character-with-s-value lput item [index-char-in-use] of turtle x [obtained-char-list] of turtle x character-with-s-value
          ]
          if who = turtle-to-follow [type [match-valutation] of turtle x type " - " type item [index-char-in-use] of turtle x [obtained-char-list] of turtle x type ", "]

      ]
      if who = turtle-to-follow [type "\n"]
      ;;get the agent list of champions that already win a chest and remove them from the list
      foreach char-obtain-chest[ [x]-> set character-with-s-value remove x character-with-s-value ]

      ;;remove duplicate champion from the list
      set character-with-s-value remove-duplicates character-with-s-value

      ;;if there is available character, get it and use them in order to get a chest
      if length character-with-s-value > 0 [
        set character-with-s-value shuffle character-with-s-value
        if who = turtle-to-follow [type "i win with the char   " type item 0 character-with-s-value type "\n"]
        get-chest who item 0 character-with-s-value
      ]

    ]
  ]

end

;This method check if an agent is elegible to get a chest
to get-chest[agent char]
  ask turtle agent[
    if chest-busy-slot < 3 [
        set char-obtain-chest lput char char-obtain-chest
        set drop-something true

        set satisfaction satisfaction + bartle-value-modifer chest-value
        set day-from-last-drop 0
        set chest-quantity chest-quantity + 1
        set chest-busy-slot chest-busy-slot + 1
        if who = turtle-to-follow [type "CHEST GAINED, my list of char that obtain a chest is  " type char-obtain-chest type ", the satisfaction now is " type satisfaction  type "\n"]
    ]
  ]
end

;This method analyze if the chest of the keys should be reset
to key-and-chest-days-reset
  ask turtles[

    if ticks != my-tick and remainder (ticks - my-tick) 30 = 0 [
      set day-from-first-key -1
      set how-many-keys 0
    ]
    if remainder ticks 365 = 0 and ticks != 0 [
      set char-obtain-chest []
    ]
    if remainder ticks 7 = 0 and ticks != 0 and chest-busy-slot > 0 [
      set chest-busy-slot chest-busy-slot - 1
    ]

  ]
end


;This method return a modified value according with bartle type
to-report bartle-value-modifer [s]

if(bartle-type = 65)[ set s s * ach-multip ]
if(bartle-type = 45)[ set s s * exp-multip ]
if(bartle-type = 105)[ set s s * soc-multip ]
if(bartle-type = 15)[ set s s * kill-multip ]

report s
end


;;This method defines the probability (for each agent) to get a key fragment
to drop-key-fragment
  ask turtles[
    if iwin = 1 [
      ;;MUST BE SET THE CORRECT PROBABILITY
      ;;: (80+(numberOfPartyMembers-1)*2)/(keyAlreadyDropped+1)
      let prob 0
      set prob (80 + (( length check-friends-in-team-of(who) ) * 2 )) / ( how-many-keys + 1 )
      if random 100 < prob
      [
        set drop-something true

        set satisfaction satisfaction + bartle-value-modifer key-value
        if who = turtle-to-follow [type "KEY-FRAG GAINED, my list of key frag that obtain a key is  " type key-fragment-quantity type ", the satisfaction now is " type satisfaction  type "\n"]
        set day-from-last-drop 0
        set how-many-keys how-many-keys + 1
        set key-fragment-quantity key-fragment-quantity + 1
        if day-from-first-key = -1 [
              set day-from-first-key 0
              set my-tick ticks
        ]
      ]
      ;If the number of key-fragment is equal or bigger than 3, it will be transformed in a key
      if key-fragment-quantity >= 3
      [
        set key-quantity key-quantity + 1
        set key-fragment-quantity key-fragment-quantity - 3
      ]
    ]

    if day-from-first-key > -1  [
      set day-from-first-key day-from-first-key + 1
    ]

  ]

end

;;This method moves the agents (during the teams creation) in order to play friends together
to reorder-for-friends
 foreach team-players-list[
   [x]->
    if(random approximation < play-with-friend-prob * approximation and length [personal-friend-list] of turtle x > 0)[

      ;;select a friend
      let what-friend 0
      set what-friend random length [personal-friend-list] of turtle x
      ;;extract friend id

      let friend 0
      set friend item what-friend ( [personal-friend-list] of turtle x )

      ;;find the friend in the list
      let friend-position 0
      set friend-position position friend team-players-list

      ;;find x in the list
      let x-position 0
      set x-position position x team-players-list

      ;;set distance from x
      let pos 0
      set pos ( random 2 + 1 )
      if((random 2 < 1 and x-position > 1) or x-position >= length team-players-list - 2) [set pos pos * -1]

      ;;move the friend
      let temporary-who 0
      set temporary-who item (x-position + pos) team-players-list


      if friend-position != false [      ;if the friend does not play, friend-position is equal to false

          let friend-team 0
          set friend-team [turtle-team] of turtle friend
          let who-team 0
          set who-team [turtle-team] of turtle temporary-who

          ask turtle friend [ set turtle-team who-team ]
          ask turtle temporary-who [ set turtle-team friend-team]

          set team-players-list replace-item friend-position team-players-list temporary-who
          set team-players-list replace-item (x-position + pos) team-players-list friend

      ]

    ]
 ]

end

;This method checks (after a match) if some players will become friends
to distribute-friends
  let i 0
  while[i < team-number][
    ;If the match was a "winning match", the probability to get a friend is higher
    let my-win-value 0
    set my-win-value item i winning-list
    let team []
    set team item i team-player-matrix

    ;;SET THE FRIEND LIST
    if my-win-value = 0 [ set my-win-value 0.5 ] ;; usefull in order to lower the probability if the team loss

    foreach team [
    [x] ->
        foreach team[
          [y]->
               if x != y and position y [personal-friend-list] of turtle x = false and length [personal-friend-list] of turtle x < max-friends-list and length [personal-friend-list] of turtle y < max-friends-list
               [
                 if random approximation < (approximation * friend-probability * my-win-value)
                 [
                   ask turtle x [ set personal-friend-list lput y personal-friend-list ]
                   ask turtle y [ set personal-friend-list lput x personal-friend-list ]
                 ]
               ]
        ]
    ]
    set i i + 1
  ]
end

;Reset the turtles parameters
to reset-turtles
  ask turtles [
     set iwin 0
     set turtle-team -1
     set drop-something false
  ]
end

;Create a matrix with the teams that partecipate at the "day match"
to create-team-matrix
  set team-player-matrix []
  let temp []
  let i 0
  while [i < team-number]
  [
    let team []
    set team [who] of turtles with [ turtle-team = i ]
    ;if item i winning-list = 1
    ;[
      set temp lput team temp
    ;]
    set i i + 1
  ]
  set team-player-matrix temp
end


;It defines the winning teams
to define-winning-team
  set winning-list []

  foreach team-player-matrix
  [
    [x]->
    let random-number 0
    let tot-prob 0.0
    let team []
    set team x
    let prob []
    foreach team[
      [k]->
        set prob lput [win-prob] of turtle k prob
    ]
    set tot-prob mean prob
    ;here i have to get the mean of prob and save the result into tot-prob
    if random approximation < tot-prob * approximation [ set random-number 1]
    set winning-list lput random-number winning-list

 ]

end

;Set the agent winning paramenter according with the team winning parameter
to distribute-winning-among-players
  ask turtles[
    ifelse ( turtle-team = -1 or iwin = -1 ) [set iwin -1] [
      ifelse ( ( item turtle-team winning-list ) = 1) [set iwin 1][set iwin 0]
    ]
  ]
end


;Count the number of occurences in the winning list
to-report occurrences-in-winning-list
  let x 1
  report reduce
    [ [occurrence-count next-item] -> ifelse-value (next-item = x) [occurrence-count + 1] [occurrence-count] ] (fput 0 winning-list)
end


;Count the number of occurences of x in a list (myList)
to-report occurrences-in-list[x myList]
  report reduce
    [ [occurrence-count next-item] -> ifelse-value (next-item = x) [occurrence-count + 1] [occurrence-count] ] (fput 0 myList)
end


;this methods check if an agent is elegible to partecipate at a match
to-report able-players
  let players []
  ;;Define the probability to get a match
  foreach turtle-list[
    [x] ->
    let prob 0
    set prob [ game-time ] of turtle x
    ifelse random 100 < prob
    [
      set players lput x players
    ]
    [
      ask turtle x[ set iwin -1 ]
    ]
  ]
  report players

end

;It creates the teams that will be able to gain a match
to create-a-team
  shuffle-turtle-list
  let i 0
  let j 0

  set players-able-to-play []
  set players-able-to-play able-players

  let temporaryList []
  foreach players-able-to-play
  [ [x] ->
    ;If the team is complete (>= 5), it moves to another team
    if i >= 5
    [
       set j j + 1
       set i 0
    ]
    ask turtle x[ set turtle-team j ]
    set i i + 1
  ]
  if i != 5 [
    ask turtles with [ turtle-team = j ] [ set turtle-team -1 ]
    set j j - 1
  ]

  set team-number j + 1
  set team-players-list get-players-that-play(i)

end

;Return a list to players that are able to play
to-report get-players-that-play[ i ]
  let myList []
  set myList turtle-list

  if i != 5 [
      let k 0
      while [ k <= i ]
      [
        set myList remove-item ( length myList - 1 ) myList
        set k k + 1
      ]
  ]
  report myList

end


to shuffle-turtle-list
    set turtle-list shuffle turtle-list
end

to-report how-many-groups
    report lower-round ( ( length turtle-list ) / 5 )
end

;check the agents that are friend of agent i and are in the same team
to-report check-friends-in-team-of[i]
  let result []
  if ( [ turtle-team ] of turtle i  != -1 and  [ turtle-team ] of turtle i  != team-number) [
      let team []
      set team item [ turtle-team ] of turtle i team-player-matrix

      let friends []
      set friends [personal-friend-list] of turtle i

       foreach team[
       [x]->
        foreach friends [
           [y]->
           if y = x [set result lput x result]
        ]
      ]
  ]
  report result
end



to-report get-empty-list [a]
  let myList []
  let i 0
  while [i < a]
  [
    set myList lput 0 myList
  ]

end

to-report lower-round [a]
  let b 0
  let c 0
  set b round a
  set c a - b
  ifelse c >= 0 [report b][report b - 1]
end

to set-turtle-list
  set turtle-list []
  let i 0
  while [i < starting-players]
    [
        set turtle-list lput i turtle-list
        set i i + 1
    ]
  shuffle-turtle-list
end

;Check if the setted data are correct
to-report check-data

  ;Check if the data are setted correctly
  let percentage-value 0
  set percentage-value achiever-number + explorer-number + socializer-number + killer-number
  if percentage-value != 1 [
    output-print "bartle type percentage is incorrect, the sum must be equal to 1"
    output-print percentage-value
    report false
  ]

  set percentage-value n-casual + n-mid + n-hardcore
  ifelse percentage-value != 1 [
    output-print "game-time distribution (percentage) is incorrect, the sum must be equal to 1"
    let s 0.0
    ;It autocorrects the data
    set s n-casual + n-mid
    set hardcore 1 - s
    set casual n-casual
    set mid n-mid
  ]
  [
    set hardcore n-hardcore
    set casual n-casual
    set mid n-mid
  ]

  if p-casual > 1 or p-casual < 0 or p-mid > 1 or p-mid < 0 or p-hardcore > 1 or p-hardcore < 0 [
    output-print "the probability to get (game-time) a match must be between 0 and 1"
    report false
  ]


   if play-with-friend-prob > 1 or play-with-friend-prob < 0  [
    output-print "the value of play-with-friend-prob must be between 0 and 1"
    report false
  ]

  if max-friends-list < 0 [
    output-print "the friend list must be >= 0"
    report false
  ]

  if friend-probability  < 0 or friend-probability > 1 [
    output-print "the friend probability must be a value between 0 and 1"
    report false
  ]


  report true
end

;It modifies the paramenter of "turtle-to-follow"
to modify-turtle-to-follow

  ask turtle turtle-to-follow [
    set size size * 3

    let i 0

  let temp-value 0

  let a-numb 0
  set a-numb achiever-number * ( approximation  ) + temp-value
  set temp-value a-numb
  let e-numb 0
  set e-numb explorer-number * ( approximation  ) + temp-value
  set temp-value e-numb
  let s-numb 0
  set s-numb socializer-number * ( approximation ) + temp-value
  set temp-value s-numb
  let k-numb 0
  set k-numb killer-number * ( approximation ) + temp-value
  set temp-value k-numb

    let bart-value 0
    if(bartle-type-turtle-to-follow = "random") [set bart-value random approximation]
    if(bartle-type-turtle-to-follow = "achiever") [set bart-value a-numb - 1]
    if(bartle-type-turtle-to-follow = "explorer") [set bart-value e-numb - 1]
    if(bartle-type-turtle-to-follow = "socializer") [set bart-value s-numb - 1]
    if(bartle-type-turtle-to-follow = "killer") [set bart-value k-numb - 1]

      set i 0

  set temp-value 0

  let c-numb 0
  set c-numb casual * ( approximation  ) + temp-value
  set temp-value c-numb
  let m-numb 0
  set m-numb mid * ( approximation  ) + temp-value
  set temp-value m-numb
  let h-numb 0
  set h-numb hardcore * ( approximation ) + temp-value
  set temp-value h-numb

  let game-value 0
      if(bartle-type-turtle-to-follow = "random") [set game-value random approximation]
    if(bartle-type-turtle-to-follow = "casual") [set game-value c-numb - 1]
    if(bartle-type-turtle-to-follow = "mid") [set game-value m-numb - 1]
    if(bartle-type-turtle-to-follow = "hardcore") [set game-value h-numb - 1]

    set win-prob 0
    ;;BARTLE TYPE
    define-bartle-type who bart-value
    ;;GAME TIME
    define-game-type who game-value
    set win-prob win-prob / 2
  ]

end


;It defines the agent starting parameter
to define-agents-types

 ask turtles [


  set win-prob 0
  ;;BARTLE TYPE
  define-bartle-type who random approximation
   ;;GAME TIME
  define-game-type who random approximation
  set win-prob win-prob / 2

    ;;PARTY-PROBABILITY


  ;;SET STARTING VALUES
  set personal-friend-list []
  set chest-quantity 0
  set key-quantity 0
  set key-fragment-quantity 0
  set days-do-not-win 0
  set how-many-keys 0
  set how-many-characters number-starting-char
  set obtained-char-figure-list []
  set char-obtain-chest []
  set day-from-first-key 0
  set day-from-last-drop 0
  set drop-something false
  set index-char-in-use 0
  set chest-busy-slot 0

  ;;Define starting char
  set obtained-char-list []
  let temporary-list []
  set temporary-list n-values 136 [ [v] -> v ]
  set temporary-list shuffle temporary-list

  let z 0
  while [z < number-starting-char][
    set obtained-char-list lput item z temporary-list obtained-char-list
    set z z + 1
  ]
]

  ;;set the list of character, the skins and the favorite character by agents
  set character-list n-values 136 [[k] -> k]
  set ulti-skin-by-char-list []
  set mid-skin-by-char-list []
  set norm-skin-by-char-list []
  foreach character-list[
    [x]->
      set ulti-skin-by-char-list lput random 2  ulti-skin-by-char-list
      set mid-skin-by-char-list lput (( random 3 ) + 1 ) mid-skin-by-char-list
      set norm-skin-by-char-list lput ((random 2 ) + 1 ) norm-skin-by-char-list
  ]

  set total-skin-number sum ulti-skin-by-char-list + sum mid-skin-by-char-list + sum norm-skin-by-char-list

  ;Set the lists of favorite items
  ask turtles [
    set favorite-character-list shuffle character-list
    set obtained-ulti-skin-list n-values 136 [0]
    set obtained-mid-skin-list n-values 136 [0]
    set obtained-norm-skin-list n-values 136 [0]

    set obtained-ulti-fig-skin-list n-values 136 [0]
    set obtained-mid-fig-skin-list n-values 136 [0]
    set obtained-norm-fig-skin-list n-values 136 [0]

    set obtained-ward n-values 34 [[k] -> k]
    set obtained-icons n-values 192 [[k] -> k]
    set obtained-ward shuffle obtained-ward
    set obtained-icons shuffle obtained-icons

    set interessed-ward n-values 34 [0]
    set interessed-icons n-values 192 [0]

    let k n-values (( random 3) + (ward-number - 1)) [0]
    let f 0

   while [f < length k][
     set interessed-ward replace-item item f obtained-ward interessed-ward 1
     set f f + 1
   ]

   set k n-values (( random 3) + (icon-number - 1)) [0]
   set f 0

   while [f < length k][
     set interessed-icons replace-item item f obtained-icons interessed-icons 1
     set f f + 1
   ]

   set obtained-ward n-values 34 [0]
   set obtained-icons n-values 192 [0]

 ]

end

;Generate the agents feature of Bartle-Type according with the statistics data revealed by the survey
to define-bartle-type[agent rand_value]

  let i 0
  let temp-value 0

  ;defines the bartle type according with the survey probability
  let a-numb 0
  set a-numb achiever-number * ( approximation  ) + temp-value
  set temp-value a-numb
  let e-numb 0
  set e-numb explorer-number * ( approximation  ) + temp-value
  set temp-value e-numb
  let s-numb 0
  set s-numb socializer-number * ( approximation ) + temp-value
  set temp-value s-numb
  let k-numb 0
  set k-numb killer-number * ( approximation ) + temp-value
  set temp-value k-numb



    ask turtle agent [
      let temporary-random-selection 0
      set temporary-random-selection rand_value

      ifelse temporary-random-selection <= a-numb
          [
            set bartle-type 65
            set win-prob win-prob + ach-win
          ] ;; here the agent is an achiever
          [
             ifelse temporary-random-selection <= e-numb
                 [
                   set bartle-type 45
                   set win-prob win-prob + exp-win
                 ] ;; here the agent is an explorer
                 [
                     ifelse temporary-random-selection <= s-numb
                     [
                       set bartle-type 105
                       set win-prob win-prob + soc-win
                     ] ;;here the agent is a socializer
                     [
                       set bartle-type 15
                       set win-prob win-prob + kill-win
                     ] ;;here the agent is a killer
                 ]
      ]

      set color bartle-type
    ]

end


;Generate the agents feature of Game-Time according with the statistics data revealed by the survey
;The Game-time is defined according with the bartle type and the survey data
to define-game-type[agent rand_value]

ask turtle agent[

  ;If the agent is an achiever
  if(bartle-type != 65 AND bartle-type != 45 AND bartle-type != 105 AND bartle-type != 15) [define-bartle-type agent random approximation]
  if bartle-type = 65[
     let i 0

     let temp-value 0

     let myCasual 0.416666667

     let myMid 0.25
     let myHard 0.333333333



     let c-numb 0
     set c-numb myCasual * ( approximation  ) + temp-value
     set temp-value c-numb
     let m-numb 0
     set m-numb myMid * ( approximation  ) + temp-value
     set temp-value m-numb
     let h-numb 0
     set h-numb myHard * ( approximation ) + temp-value
     set temp-value h-numb

     let temporary-random-selection 0
     set temporary-random-selection rand_value

     ifelse temporary-random-selection <= c-numb
     [
        set game-time p-casual * 100
        set shape "wheel"
        set win-prob win-prob + casual-win
     ] ;; here is a casual
     [
        ifelse temporary-random-selection <= m-numb
        [
            set game-time p-mid * 100
            set shape "car"
            set win-prob win-prob + mid-win
        ] ;; here is a midcore
        [
            set game-time p-hardcore * 100
            set shape "airplane"
            set win-prob win-prob + hardcore-win
        ] ;here is an hardcore
     ]

  ]

  ;If the agent is an eplorer
  if bartle-type = 45 [

         let i 0

     let temp-value 0

     let myCasual 0.692307692

     let myMid 0.153846154

     let myHard 0.153846154



     let c-numb 0
     set c-numb myCasual * ( approximation  ) + temp-value
     set temp-value c-numb
     let m-numb 0
     set m-numb myMid * ( approximation  ) + temp-value
     set temp-value m-numb
     let h-numb 0
     set h-numb myHard * ( approximation ) + temp-value
     set temp-value h-numb

     let temporary-random-selection 0
     set temporary-random-selection rand_value

     ifelse temporary-random-selection <= c-numb
     [
        set game-time p-casual * 100
        set shape "wheel"
        set win-prob win-prob + casual-win
     ] ;; here is a casual
     [
        ifelse temporary-random-selection <= m-numb
        [
            set game-time p-mid * 100
            set shape "car"
            set win-prob win-prob + mid-win
        ] ;; here is a midcore
        [
            set game-time p-hardcore * 100
            set shape "airplane"
            set win-prob win-prob + hardcore-win
        ] ;;here is an hardcore
     ]

  ]


  ;If the agent is a killer
  if bartle-type = 15 [

      let i 0

     let temp-value 0

     let myCasual 0.363636364

     let myMid 0.454545455

     let myHard 0.181818182

     let c-numb 0
     set c-numb myCasual * ( approximation  ) + temp-value
     set temp-value c-numb
     let m-numb 0
     set m-numb myMid * ( approximation  ) + temp-value
     set temp-value m-numb
     let h-numb 0
     set h-numb myHard * ( approximation ) + temp-value
     set temp-value h-numb

     let temporary-random-selection 0
     set temporary-random-selection rand_value

     ifelse temporary-random-selection <= c-numb
     [
        set game-time p-casual * 100
        set shape "wheel"
        set win-prob win-prob + casual-win
     ] ;; here is a casual
     [
        ifelse temporary-random-selection <= m-numb
        [
            set game-time p-mid * 100
            set shape "car"
            set win-prob win-prob + mid-win
        ] ;; here is a midcore
        [
            set game-time p-hardcore * 100
            set shape "airplane"
            set win-prob win-prob + hardcore-win
        ] ;; here is an hardcore
     ]
  ]


  ;If the agent is a socializer
  if bartle-type = 105 [

     let i 0

     let temp-value 0
     let myCasual 1
     let myMid 0
     let myHard 0

     let c-numb 0
     set c-numb myCasual * ( approximation  ) + temp-value
     set temp-value c-numb
     let m-numb 0
     set m-numb myMid * ( approximation  ) + temp-value
     set temp-value m-numb
     let h-numb 0
     set h-numb myHard * ( approximation ) + temp-value
     set temp-value h-numb

     let temporary-random-selection 0
     set temporary-random-selection rand_value

     ifelse temporary-random-selection <= c-numb
     [
        set game-time p-casual * 100
        set shape "wheel"
        set win-prob win-prob + casual-win
     ] ;; here is a casual
     [
        ifelse temporary-random-selection <= m-numb
        [
            set game-time p-mid * 100
            set shape "car"
            set win-prob win-prob + mid-win
        ] ;; here is a midcore
        [
            set game-time p-hardcore * 100
            set shape "airplane"
            set win-prob win-prob + hardcore-win
        ] ;;here is an hardcore
     ]
  ]
]

end

;It generate the players
to generate-players

  create-turtles starting-players [setxy random-xcor random-ycor]


end
@#$#@#$#@
GRAPHICS-WINDOW
1262
30
1699
468
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

BUTTON
1260
470
1323
503
NIL
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
1328
470
1391
503
NIL
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
29
147
408
180
starting-players
starting-players
0
5000
11500.0
1
1
NIL
HORIZONTAL

INPUTBOX
27
186
126
246
achiever-number
0.292682927
1
0
Number

INPUTBOX
128
186
218
246
explorer-number
0.317073171
1
0
Number

INPUTBOX
221
187
319
247
socializer-number
0.12195122
1
0
Number

INPUTBOX
321
186
396
246
killer-number
0.268292682
1
0
Number

OUTPUT
1259
516
1857
628
12

MONITOR
29
255
124
300
arch-count
count turtles with [bartle-type = 65]
17
1
11

MONITOR
129
256
225
301
exp-count
count turtles with [bartle-type = 45]
17
1
11

MONITOR
228
257
322
302
soc-count
count turtles with [bartle-type = 105]
17
1
11

MONITOR
326
258
412
303
kill-count
count turtles with [bartle-type = 15]
17
1
11

INPUTBOX
31
79
186
139
s-probability
0.226174841
1
0
Number

MONITOR
801
16
904
61
agents-in-match
length team-player-matrix * 5
17
1
11

MONITOR
538
17
640
62
!agent-in-match
starting-players - length team-player-matrix * 5
17
1
11

INPUTBOX
415
136
503
196
starting-players
11500.0
1
0
Number

TEXTBOX
1725
31
1875
143
Achiever -> GREEN\nExplorer -> YELLOW\nSocializer -> BLUE\nKiller -> RED\n\nCasual -> Wheel\nMidcore -> Car\nHardcore -> Airplane
11
0.0
1

MONITOR
1095
44
1259
89
number-team
[ turtle-team ] of turtle turtle-to-follow
17
1
11

INPUTBOX
190
83
345
143
win-probability
0.5
1
0
Number

MONITOR
1257
638
1350
683
winning-teams
occurrences-in-winning-list
17
1
11

MONITOR
1359
638
1453
683
winnersTurtles
count turtles with [iwin = 1]
17
1
11

MONITOR
1462
639
1598
684
Turtles-do-not-playing
count turtles with [iwin = -1]
17
1
11

INPUTBOX
27
435
88
495
n-casual
0.536585366
1
0
Number

INPUTBOX
93
435
143
495
n-mid
0.341463415
1
0
Number

INPUTBOX
152
434
218
494
n-hardcore
0.12195122
1
0
Number

INPUTBOX
227
433
280
493
p-casual
0.33
1
0
Number

INPUTBOX
293
433
343
493
p-mid
0.66
1
0
Number

INPUTBOX
352
436
417
496
p-hardcore
0.99
1
0
Number

MONITOR
28
503
87
548
n-casual
count turtles with [game-time = p-casual * 100]
17
1
11

MONITOR
92
503
149
548
n-mid
count turtles with [game-time = p-mid * 100]
17
1
11

MONITOR
153
503
227
548
n-hardcore
count turtles with [game-time = p-hardcore * 100]
17
1
11

TEXTBOX
423
434
573
546
The first three inputs are about the distribution of the player (the sum must be equal to 1.\nThe second three inputs are about the probability of a player to get involved in a match
11
0.0
1

PLOT
20
832
1883
1539
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"turtle-to-follow" 1.0 0 -1 true "" "plot [satisfaction] of turtle turtle-to-follow"
"av-sat" 1.0 0 -13840069 true "plot avarage-satisfaction" "plot avarage-satisfaction"
"avarage-hardcore" 1.0 0 -10263788 true "plot avarage-hardcore" "plot avarage-hardcore"
"avarage-midcore" 1.0 0 -6995700 true "plot avarage-midcore" "plot avarage-midcore"
"avarage-casual" 1.0 0 -12440034 true "plot avarage-casual" "plot avarage-casual"
"avarage-archiever" 1.0 0 -1 true "plot avarage-archiever" "plot avarage-archiever"
"avarage-explorer" 1.0 0 -1 true "plot avarage-explorer" "plot avarage-explorer"
"avarage-killer" 1.0 0 -1 true "plot avarage-killer" "plot avarage-killer"
"avarage-socializer" 1.0 0 -1 true "plot avarage-socializer" "plot avarage-socializer"
"c-a" 1.0 0 -1 true "plot avarage-casual-archiever" "plot avarage-casual-archiever"
"c-e" 1.0 0 -1 true "plot avarage-casual-explorer" "plot avarage-casual-explorer"
"c-k" 1.0 0 -1 true "plot avarage-casual-killer" "plot avarage-casual-killer"
"c-s" 1.0 0 -13345367 true "plot avarage-casual-socializer" "plot avarage-casual-socializer"
"m-a" 1.0 0 -1 true "plot avarage-midcore-archiever" "plot avarage-midcore-archiever"
"m-e" 1.0 0 -1 true "plot avarage-midcore-explorer" "plot avarage-midcore-explorer"
"m-k" 1.0 0 -1 true "plot avarage-midcore-killer" "plot avarage-midcore-killer"
"m-s" 1.0 0 -1 true "plot avarage-midcore-socializer" "plot avarage-midcore-socializer"
"h-a" 1.0 0 -1 true "plot avarage-hardcore-archiever" "plot avarage-hardcore-archiever"
"h-e" 1.0 0 -1 true "plot avarage-hardcore-explorer" "plot avarage-hardcore-explorer"
"h-k" 1.0 0 -2674135 true "plot avarage-hardcore-killer" "plot avarage-hardcore-killer"
"h-s" 1.0 0 -1 true "plot avarage-hardcore-socializer" "plot avarage-hardcore-socializer"
"pen-22" 1.0 0 -16448764 true "" "plot 0"

MONITOR
1606
638
1693
683
NIL
team-number
17
1
11

MONITOR
1462
466
1539
511
temp-count
length [who] of turtles with [ turtle-team = 0 ]
17
1
11

INPUTBOX
31
304
119
364
max-friends-list
40.0
1
0
Number

INPUTBOX
31
364
124
424
friend-probability
0.1
1
0
Number

TEXTBOX
138
308
288
420
max-friends-list define the maximum number of frieds for a single agent.\nfriend-probability define the probability after a winning to add a member to a friend list (if the player loses the probability is lower)
11
0.0
1

INPUTBOX
926
30
1081
90
turtle-to-follow
0.0
1
0
Number

MONITOR
927
98
1260
143
friends
[personal-friend-list] of turtle turtle-to-follow
17
1
11

MONITOR
927
149
1024
194
friends-in-team
length check-friends-in-team-of(turtle-to-follow)
17
1
11

MONITOR
650
16
799
61
number-generated-team
team-number
17
1
11

INPUTBOX
295
332
429
392
play-with-friend-prob
0.8
1
0
Number

MONITOR
1029
148
1117
193
key-fragment
[key-fragment-quantity] of turtle turtle-to-follow
17
1
11

MONITOR
1122
148
1179
193
key
[key-quantity] of turtle turtle-to-follow
17
1
11

MONITOR
925
198
1031
243
day-from-first-key
[day-from-first-key] of turtle turtle-to-follow
17
1
11

MONITOR
1181
146
1264
191
chest-quantity
[chest-quantity] of turtle turtle-to-follow
17
1
11

MONITOR
1035
197
1154
242
how-many-characters
[length obtained-char-list] of turtle turtle-to-follow
17
1
11

CHOOSER
746
96
920
141
bartle-type-turtle-to-follow
bartle-type-turtle-to-follow
"random" "achiever" "explorer" "socializer" "killer"
1

CHOOSER
745
153
915
198
game-time-turtle-to-follow
game-time-turtle-to-follow
"random" "casual" "mid" "hardcore"
3

MONITOR
1161
199
1254
244
char-fragment
[number-frag-char] of turtle turtle-to-follow
17
1
11

MONITOR
1163
247
1252
292
skin-fragment
[number-frag-skin] of turtle turtle-to-follow
17
1
11

INPUTBOX
32
12
187
72
my-seed
13.0
1
0
Number

SWITCH
189
23
338
56
my-random-seed
my-random-seed
1
1
-1000

MONITOR
927
246
1029
291
how-many-skin-obtained
[sum obtained-ulti-skin-list + sum  obtained-mid-skin-list + sum obtained-norm-skin-list] of turtle turtle-to-follow
17
1
11

MONITOR
1034
245
1144
290
obtained-char-figure
[length obtained-char-figure-list] of turtle turtle-to-follow
17
1
11

MONITOR
846
245
923
290
skin-fig-n
[sum obtained-ulti-fig-skin-list + sum  obtained-mid-fig-skin-list + sum obtained-norm-fig-skin-list] of turtle turtle-to-follow
17
1
11

INPUTBOX
421
254
529
314
number-starting-char
20.0
1
0
Number

MONITOR
767
245
842
290
char-in-use
[char-in-use] of turtle turtle-to-follow
17
1
11

MONITOR
764
293
1247
338
char-of-turtle-to-follow
[obtained-char-list] of turtle turtle-to-follow
17
1
11

INPUTBOX
26
594
111
654
char-multiplier
4.333333333
1
0
Number

INPUTBOX
120
595
220
655
ulti-skin-multiplier
16.256410256
1
0
Number

INPUTBOX
227
595
330
655
mid-skin-multiplier
8.128205128
1
0
Number

INPUTBOX
334
594
444
654
norm-skin-multiplier
4.064102564
1
0
Number

INPUTBOX
448
596
513
656
ward-value
4.153846154
1
0
Number

INPUTBOX
516
596
585
656
icons-value
3.794871795
1
0
Number

INPUTBOX
900
704
972
764
icon-number
34.0
1
0
Number

INPUTBOX
818
704
896
764
ward-number
7.0
1
0
Number

INPUTBOX
592
599
655
659
gem-value
7.358974359
1
0
Number

INPUTBOX
27
658
114
718
unsat-multiplier
0.5
1
0
Number

INPUTBOX
117
660
190
720
chest-value
6.358974359
1
0
Number

INPUTBOX
192
656
260
716
key-value
7.794871795
1
0
Number

MONITOR
786
198
863
243
satisfaction
[satisfaction] of turtle turtle-to-follow
17
1
11

INPUTBOX
340
14
429
74
number-of-days
2000.0
1
0
Number

SWITCH
395
77
585
110
defined-number-of-days
defined-number-of-days
0
1
-1000

INPUTBOX
28
733
107
793
ach-multip
2.0
1
0
Number

INPUTBOX
113
734
181
794
exp-multip
1.5
1
0
Number

INPUTBOX
187
733
255
793
soc-multip
1.0
1
0
Number

INPUTBOX
261
734
326
794
kill-multip
1.2
1
0
Number

INPUTBOX
693
596
775
656
hardcore-win
0.8
1
0
Number

INPUTBOX
774
596
834
656
mid-win
0.5
1
0
Number

INPUTBOX
833
597
898
657
casual-win
0.3
1
0
Number

INPUTBOX
919
597
970
657
ach-win
0.5
1
0
Number

INPUTBOX
973
596
1030
656
exp-win
0.6
1
0
Number

INPUTBOX
1030
596
1089
656
soc-win
0.2
1
0
Number

INPUTBOX
1091
598
1141
658
kill-win
0.8
1
0
Number

MONITOR
1148
354
1246
399
chest-busy-slot
[chest-busy-slot] of turtle turtle-to-follow
17
1
11

TEXTBOX
886
348
1036
390
These are information about a single turtle. On this turtle you can modify the parameters. 
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

It is a simulation in order to investigate the player satisfaction under the Looting System (LS) of the most diffuse MOBA game, i.e. League of Legend (LoL).
It is also a pioneer in introducing LSs. For these reasons, we have decided to use LoL as a case study to verify to what extent the presence of an “official” LS, managed by the company producing the game, can increase the satisfaction of players, as any valid rewarding system. To increase the reliability of our findings, we have decided to base the structure of our simulation on real data, both quantitative and qualitative. For this purpose, we have interviewed a group of LoL players, both from Italy and Finland; also, we asked LoL’s player to answer an online survey. Starting from the data collected, we have set up this simulation aimed at measuring how much their satisfaction with the game is influenced by the LS. 

## HOW IT WORKS AND HOW TO USE IT

The parameters of the simaulation are already setted with the survey parameter.
Anyway, almost all parameter can be modified in the interface tab.

Thus, the enviroment can be consider plug and play. To use it with the default paramenter, the user should click on setup button and, after that, the go button.

Anyway, in the interface tab, the user can modify these parameters:

- "my-seed" and "my-random-seed": If my random seed is setted to off, the enviroment use seed described in "my-seed" in order to allow the simulation reproducibility;
- "number-of-days": defines the simulation length. If "the defined-number-of-days" is setted to off, the simulation proceeds infinitely;
- The "*-number" and "n-*" input window defines the agent topology distribution;
- The "number-starting-char" defines the number of starting characters of each agent;
- "max-friends-list" defines the maximum number of frieds for a single agent;
- "friend-probability" defines the probability after a winning to add a member to a friend list (if the player loses the probability is lower);
- "play-with-friend-prob" defines the probabilty to insert a friend in agent team
- "p-casual/mid/hardcore" input monitors define the probability to involve the agent in a match;
- The bottom-left input monitors define the satisfaction values regarding the LS;
- The input monitors with "*-win" define the probability of each agent to help the team to winning the match;
- The "ward-number" and "icon-number" define the number of favorite item (randomly generated) of, respectively, wards and icons.

Lastly, the plot area on the bottom visualize the satisfaction graph. It can be exported in a ".csv" file using the contextual menu.


## THINGS TO NOTICE

The enviroment uses the text output consiedring the point of view of turtle-to-follow.

## CREDITS AND REFERENCES

This simulation and the simulation outcome will be presented in the special issue on "Agent-based Modelling and Simulation" of the journal "Special Issue on Agent-based Modelling and Simulation".

Credits:
Laura A. Ripamonti
Marco Granato
Antti Knutas
Marco Trubian
Davide Gadia
Dario Maggiorini


## HOW TO CITE



## COPYRIGHT AND LICENSE

Copyright 2017 Marco Granato.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: "Multi-Agent Simulations for the Evaluation of Looting Systems Design in MMO Games".

<!-- 2017 Cite: To Define -->




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
