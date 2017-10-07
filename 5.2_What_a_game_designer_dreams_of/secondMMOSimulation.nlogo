turtles-own [
  class ; For each agent there are 4 different classes availables: warrior, magician, priest, and thief
  typology ;the 4 bartle type typology: socializer, explorer, achiever, killer
  present_pleasure  ;pleasure index
  preference  ;preferences of a praticular item
  miss_partecipation ;it could be 0 or 1, ant it describe if the agent is in a mission
  count_item ; total of received items
  count_mission ;total number of mission
  
                ;The following argouments describe, for each available items, which is the item (possessed by a user) with the higher value
  warrior_poss_value00
  warrior_poss_value01
  warrior_poss_value02
  magician_poss_value00
  magician_poss_value01
  magician_poss_value02
  priest_poss_value00
  priest_poss_value01
  priest_poss_value02
  thief_poss_value00
  thief_poss_value01
  thief_poss_value02
  generic_poss_value00
  generic_poss_value01
  generic_poss_value02
  
  ;variables for Rolling
  dice
  
  ;variables for Karma
  karma_dice ;itis the sum of the dice and a possible bonus
  karma_points ; tot karma points
  use_karma ; 0 or 1, it is used for highlight if a bonus was used
  
            ;variables for Pure List and Suicide Kings
  list_pos
  
  ;variables for DKP LSs
  dkp_points
  auction_offer ; it is used for save the auction offers (in DKP with auction LS)
  spent_points ; this is used on DKP Relational LS
  
               ;variables for Dual Token
  need_token
  greed_token
]

globals [
  ;_______________________________________________
  ;These list record the pleasure for each categories
  socializer_list
  explorer_list
  achiever_list
  killer_list
  
  ;________________________________________________
  ls_in_use ;it indicates which LS to use
  mission_num_items ;it idicates how many items are available in the missions
  class_list ;the available classes
  item_list ;the available items
  finded_item ;it is defined by the function find_item
  item_value ;it is defined by the function find_item
  tax ;0 o 1, explicit if the taxes are active
  group ;list of participants in the group
  
        ; Variables used in calc_members_preference to calculate the preference for an object, each member of the group
  class_weight; how much it affects the class of membership
  bartle_weight; how much it affects the player
  redundacy_weight; as it affects the possession of equal or inferior items
  received_items_weight;how much the number of objects received in relation to the missions to which the agent participated affects
  character_x; var character to calculate the preference for a item or the value of objects of a certain type possessed
  
             ;variables to set the population division according to Bartle's typologies
  population ; total population
  dominant_typology ; dominant choice typology
  remaining_typology_list ;the others 3 typology
  perc_dominant_typology ; dominance percentual of the chosen typology
  num_dominant_typology ; exact number of agents corresponding to the chosen percentage
]

to setup
  clear-all
  ; Based on the whole that will be assigned to the ls_in_use variable you will choose which system to use
  ; 0 Rolling
  ; 1 Karma
  ; 2 Pure List
  ; 3 Suicide Kings
  ; 4 DKP with variable prices
  ; 5 DKP with fixed prices
  ; 6 DKP wit auction
  ; 7 DKP Zero-Sum
  ; 8 DKP Relational
  ; 9 Dual Token
  set ls_in_use 0
  set tax 0 ; 0 o 1, for the Karma system and DKP systems, it indicates whether agents' points are periodically taxed
  
            ; indicates the number of items that can be found in each mission
  set mission_num_items 6
  set dominant_typology "killer" ; dominant typology
  set remaining_typology_list ["explorer" "socializer" "achiever"] ; other typology
  set perc_dominant_typology 70 ; choice of the percentage of dominance
  set population 500 ; total population
  set item_list [ ;list of available items, 3 for each class and 3 for a generic class
    "warrior_item00" "warrior_item01" "warrior_item02" ;class-specific warrior
    "magician_item00" "magician_item01" "magician_item02" ;class-specific magician
    "priest_item00" "priest_item01" "priest_item02" ;class-specific priest
    "thief_item00" "thief_item01" "thief_item02" ;class-specific thief
    "generic_item00" "generic_item01" "generic_item02" ;for each classes
  ]
  set class_list [ ; list of available classes
    "warrior" 
    "magician"
    "priest" 
    "thief" 
  ]
  setup-turtles
end


to setup-turtles
  let list_counter 0; iterator used for Pure List
  
  set num_dominant_typology ((population) * perc_dominant_typology / 100)
  
  create-turtles population ; create agents
  [
    set class one-of class_list ; assign at the agents a random class
    
                                ; it defines starting lists for Pure List and Suicide Kings
    set list_pos list_counter
    set list_counter list_counter + 1
    ; starting spend point for DKP Relational
    set spent_points 1
    ifelse who < num_dominant_typology ; it defines the dominant typology
    [ set typology dominant_typology ]
    [ set typology one-of remaining_typology_list ] ; random typology for others
  ]
end

to go
  if(ticks = 49905)[ ;after 500 missions the simulation stops
    set socializer_list [ ]
    set explorer_list [ ]
    set achiever_list [ ]
    set killer_list [ ]
    ; here the data was stored
    foreach sort turtles[
      if([typology] of ? = "socializer")[
        set socializer_list fput ([present_pleasure] of ?) socializer_list
      ]
      if([typology] of ? = "explorer")[
        set explorer_list fput ([present_pleasure] of ?) explorer_list
      ]
      if([typology] of ? = "achievers")[
        set achiever_list fput ([present_pleasure] of ?) achiever_list
      ]
      if([typology] of ? = "killer")[
        set killer_list fput ([present_pleasure] of ?) killer_list
      ]
    ]
    STOP
  ]
  if ((ticks mod 100) = 0)[ ; start a new mission
    create_group
    mission_partecipation
  ]
  ;apply tax (if they are active)
  if (((ticks mod 50) = 0) AND (tax != 0))[
    let percentuale_tax 2
    foreach sort turtles[
      if([karma_points] of ? > 0)[
        ask ? [ set karma_points int (karma_points - (karma_points * percentuale_tax / 100))]
      ]
      if([dkp_points] of ? > 0)[
        ask ? [ set dkp_points int (dkp_points - (dkp_points * percentuale_tax / 100))]
      ]
      if([spent_points] of ? > 1)[
        ask ? [ set spent_points int (spent_points - (spent_points * percentuale_tax / 100))]
      ]
    ]
  ]
  
  tick
end

to create_group
  ;each group is structured by 5 members, with at least: 1 warrior, 1 magician, 1 priest
  ;the others are assigned randomly
  
  let warriors_list [ ]
  let mage_list [ ]
  let priests_list [ ]
  let lista_ladri [ ]
  set group [ ]
  foreach sort turtles[
    if ([class] of ? = "warrior")[
      set warriors_list fput ? warriors_list
    ]
    if ([class] of ? = "magician")[
      set mage_list fput ? mage_list
    ]
    if ([class] of ? = "priest")[
      set priests_list fput ? priests_list
    ]
    if ([class] of ? = "thief")[
      set lista_ladri fput ? lista_ladri
    ]
  ]
  ;Assign the first 3 members
  set group fput (one-of warriors_list) group
  set group fput (one-of mage_list) group
  set group fput (one-of priests_list) group
  foreach group [
    ask ? [set miss_partecipation 1]
  ]
  let candidate (one-of turtles); assign the others candidates
  while [([miss_partecipation] of candidate) = 1][
    set candidate one-of turtles
  ]
  ask candidate [set miss_partecipation 1]; flag the agent
  set group fput candidate group; add the group
  ifelse ([class] of candidate = "thief")[
    set candidate one-of turtles
    while [([miss_partecipation] of candidate) = 1][ 
      set candidate one-of turtles
    ]
    ask candidate [set miss_partecipation 1]; the agent was flagged as participant
    set group fput candidate group; add to the group
  ][
  
  ;check in order to does not have 3 characters of the same class
  let var_classe ([class] of candidate)
  while [(var_classe = ([class] of candidate)) OR (([miss_partecipation] of candidate) = 1)]
    [
      set candidate (one-of turtles)
    ]
  ask candidate [set miss_partecipation 1]
  
  set group fput candidate group
  ]
  foreach group[
    ask ? [ set count_mission count_mission + 1 ]
    if(ls_in_use = 9)[ ; assigns the token (for dual token ls)
      ask ? [
        set need_token need_token + 1
        set greed_token greed_token + 1
      ]
    ]
  ]
end

to mission_partecipation
  repeat mission_num_items[ ;proportional iteractions to the items that can be found in a mission
    find_item
    calc_members_preference
    use_loot_sys
  ]
  ; assign pleasure points according to the bartle type
  foreach group[
    if([typology] of ? = "socializer")[
      ask ? [set present_pleasure  present_pleasure  + 9]
    ]
    if([typology] of ? = "explorer")[
      ask ? [set present_pleasure  present_pleasure  + 7]
    ]
    if([typology] of ? = "achiever")[
      ask ? [set present_pleasure  present_pleasure  + 4]
    ]
    if([typology] of ? = "killer")[
      ask ? [set present_pleasure  present_pleasure  + 2]
    ]
    ask ? [
      set preference 0
      set miss_partecipation 0
      set need_token 0
      set greed_token 0
    ]
  ]
end

to find_item
  let random_number random 550 ; item value
  set finded_item one-of item_list; random item
  
                                  ;the item value is directly proportial to the rarity
  if (random_number < 100)[
    
    set item_value 0
  ]
  if ((random_number >= 100) AND (random_number < 190))[
    set item_value 1
  ]
  if ((random_number >= 190) AND (random_number < 270))[
    set item_value 2
  ]
  if ((random_number >= 270) AND (random_number < 340))[
    set item_value 3
  ]
  if ((random_number >= 340) AND (random_number < 400))[
    set item_value 4
  ]
  if ((random_number >= 400) AND (random_number < 450))[
    set item_value 5
  ]
  if ((random_number >= 450) AND (random_number < 490))[
    set item_value 6
  ]
  if ((random_number >= 490) AND (random_number < 520))[
    set item_value 7
  ]
  if ((random_number >= 520) AND (random_number < 540))[
    set item_value 8
  ]
  if ((random_number >= 540) AND (random_number < 550))[
    set item_value 9
  ]
end

to calc_members_preference
  foreach group[
    set character_x ?
    ask character_x [set preference preference + item_value]
    calc_class_weight
    calc_bartle_weight
    calc_redundacy_weight
    calc_received_items_weight
  ]
end

to calc_class_weight
  ;if an item is of the same class of the character, than it adds 9 point to the pleasure
  ;if an item is generic, it adds 5 points to the pleasure 
  
  ;=================================
  ;=========== warrior ===========
  ;=================================
  if (([class] of character_x = "warrior") AND
    (
      (finded_item = "warrior_item00") OR (finded_item = "warrior_item01") OR (finded_item =
        "warrior_item02")
    ))
  [
    ask character_x [set preference preference + 9]
  ]
  ;=================================
  ;============== magician =============
  ;=================================
  if (([class] of character_x = "magician") AND
    (
      (finded_item = "magician_item00") OR (finded_item = "magician_item01") OR (finded_item = "magician_item02")
    
    ))
  [
    ask character_x [set preference preference + 9]
  ]
  ;=================================
  ;============= priest =============
  ;=================================
  if (([class] of character_x = "priest") AND
    (
      (finded_item = "priest_item00") OR (finded_item = "priest_item01") OR (finded_item = "priest_item02")
    ))
  [
    ask character_x [set preference preference + 9]
  ]
  ;=================================
  ;============= thief =============
  ;=================================
  if (([class] of character_x = "thief") AND
    (
      (finded_item = "thief_item00") OR (finded_item = "thief_item01") OR (finded_item = "thief_item02")
    ))
  [
    ask character_x [set preference preference + 9]
  ]
  ;=================================
  ;============ generic ===========
  ;=================================
  if((finded_item = "generic_item00") OR (finded_item = "generic_item01") OR (finded_item =
    "generic_item02"))
  [
    ask character_x [set preference preference + 5]
  ]
end

to calc_bartle_weight
  ;=================================
  ;========== SOCIALIZER ===========
  ;=================================
  ;it adds 3 points at items of the same class of the characters
  if(([typology] of character_x = "socializer") AND (
    (([class] of character_x = "warrior") AND ((finded_item = "warrior_item00") OR (finded_item =
      "warrior_item01") OR (finded_item = "warrior_item02")))
    OR
    (([class] of character_x = "magician") AND ((finded_item = "magician_item00") OR (finded_item = "magician_item01")
      OR (finded_item = "magician_item02")))
    OR
    (([class] of character_x = "priest") AND ((finded_item = "priest_item00") OR (finded_item =
      "priest_item01") OR (finded_item = "priest_item02")))
    OR
    (([class] of character_x = "thief") AND ((finded_item = "thief_item00") OR (finded_item =
      "thief_item01") OR (finded_item = "thief_item02")))
    )
    )[
  ask character_x [set preference preference + 3]
    ]
  ;and 2 of generic items
  if(([typology] of character_x = "socializer") AND ((finded_item = "generic_item00") OR (finded_item =
    "generic_item01") OR (finded_item = "generic_item02")))
  [
    ask character_x [set preference preference + 2]
  ]
  ;=================================
  ;=========== EXPLORER ============
  ;=================================
  ;it adds 7 points at items of the same class of the characters
  if(([typology] of character_x = "explorer") AND (
    (([class] of character_x = "warrior") AND ((finded_item = "warrior_item00") OR (finded_item =
      "warrior_item01") OR (finded_item = "warrior_item02")))
    
    OR
    (([class] of character_x = "magician") AND ((finded_item = "magician_item00") OR (finded_item = "magician_item01")
      OR (finded_item = "magician_item02")))
    OR
    (([class] of character_x = "priest") AND ((finded_item = "priest_item00") OR (finded_item =
      "priest_item01") OR (finded_item = "priest_item02")))
    OR
    (([class] of character_x = "thief") AND ((finded_item = "thief_item00") OR (finded_item =
      "thief_item01") OR (finded_item = "thief_item02")))
    )
    )[
  ask character_x [set preference preference + 7]
    ]
  ;9 for generic items of type 00 and 01
  if(([typology] of character_x = "explorer") AND ((finded_item = "generic_item00") OR (finded_item =
    "generic_item01")))
  [
    ask character_x [set preference preference + 9]
  ]
  ;and 5 for generic items of type 02
  if(([typology] of character_x = "explorer") AND ((finded_item = "generic_item02")))
  [
    ask character_x [set preference preference + 5]
  ]
  ;=================================
  ;============= KILLER ============
  ;=================================
  ;it adds 9 points at items of the same class of the characters 
  if(([typology] of character_x = "killer") AND (
    (([class] of character_x = "warrior") AND ((finded_item = "warrior_item00") OR (finded_item =
      "warrior_item01") OR (finded_item = "warrior_item02")))
    OR
    (([class] of character_x = "magician") AND ((finded_item = "magician_item00") OR (finded_item = "magician_item01")
      OR (finded_item = "magician_item02")))
    OR
    (([class] of character_x = "priest") AND ((finded_item = "priest_item00") OR (finded_item =
      "priest_item01") OR (finded_item = "priest_item02")))
    OR
    (([class] of character_x = "thief") AND ((finded_item = "thief_item00") OR (finded_item =
      "thief_item01") OR (finded_item = "thief_item02")))
    )
    )[
  ask character_x [set preference preference + 9]
    ]
  ;9 for generic items of type 01 and 02
  if(([typology] of character_x = "killer") AND ((finded_item = "generic_item01") OR (finded_item =
    "generic_item02")))
  [
    ask character_x [set preference preference + 9]
  ]
  ;and 5 for generic items of type 00 and 01
  if(([typology] of character_x = "killer") AND ((finded_item = "generic_item00")))
  [
    ask character_x [set preference preference + 5]
  ]
  ;=================================
  ;============ ACHIEVER ===========
  ;=================================
  ;it adds 9 points for specific items of all classes
  if(([typology] of character_x = "achiever") AND (
    (finded_item = "warrior_item00") OR (finded_item = "warrior_item01") OR (finded_item =
      "warrior_item02") OR
    (finded_item = "magician_item00") OR (finded_item = "magician_item01") OR (finded_item = "magician_item02") OR
    (finded_item = "priest_item00") OR (finded_item = "priest_item01") OR (finded_item = "priest_item02") OR
    (finded_item = "thief_item00") OR (finded_item = "thief_item01") OR (finded_item = "thief_item02")
    ))
  [
    ask character_x [set preference preference + 9]
  ]
  ;and 8 for generic items
  if(([typology] of character_x = "achiever") AND ((finded_item = "generic_item00") OR (finded_item =
    "generic_item01") OR (finded_item = "generic_item02")))
  [
    ask character_x [set preference preference + 8]
  ]
end

to calc_redundacy_weight
  ; If you already have an item of the same value or greater, you have an increase in preference proportional to the value of the item
  ; If the value of the item is greater than the one you own it has an increase in preference of 9
  ; For generic items there is always an increase of 9  
  ifelse(((finded_item = "warrior_item00") AND ([warrior_poss_value00] of character_x >= item_value))
    OR
    ((finded_item = "warrior_item01") AND ([warrior_poss_value01] of character_x >= item_value)) OR
    ((finded_item = "warrior_item02") AND ([warrior_poss_value02] of character_x >= item_value)) OR
    ((finded_item = "magician_item00") AND ([magician_poss_value00] of character_x >= item_value)) OR
    ((finded_item = "magician_item01") AND ([magician_poss_value01] of character_x >= item_value)) OR
    ((finded_item = "magician_item02") AND ([magician_poss_value02] of character_x >= item_value)) OR
    ((finded_item = "priest_item00") AND ([priest_poss_value00] of character_x >= item_value)) OR
    ((finded_item = "priest_item01") AND ([priest_poss_value01] of character_x >= item_value)) OR
    ((finded_item = "priest_item02") AND ([priest_poss_value02] of character_x >= item_value)) OR
    ((finded_item = "thief_item00") AND ([thief_poss_value00] of character_x >= item_value)) OR
    ((finded_item = "thief_item01") AND ([thief_poss_value01] of character_x >= item_value)) OR
    ((finded_item = "thief_item02") AND ([thief_poss_value02] of character_x >= item_value))
    )[
  ask character_x [
    ; if the value of the found item is different from 0 then the increment is equal to the subtracted value of a unit
    ; if the value of the item is 0 there is no increment of preference
    if(item_value != 0)[
      set preference preference + (item_value - 1)
    ]
  ]
    ][
  ;if the value of the object is greater than the value of the object that alredy tha character has, it increments of 9 points
  ask character_x [set preference preference + 9]
    ]
end

to calc_received_items_weight
  ;it count the received items gained in the different missions
  let item_ricevuti 0
  let incr_preference 0
  
  set item_ricevuti ((([count_item] of character_x) * 100) / (([count_mission] of character_x) *
    mission_num_items))
  
  if(item_ricevuti <= 10)[
    set incr_preference 9
  ]
  if(item_ricevuti > 10 AND item_ricevuti <= 20)[
    set incr_preference 8
  ]
  if(item_ricevuti > 20 AND item_ricevuti <= 30)[
    set incr_preference 7
  ]
  if(item_ricevuti > 30 AND item_ricevuti <= 40)[
    set incr_preference 6
  ]
  if(item_ricevuti > 40 AND item_ricevuti <= 50)[
    set incr_preference 5
  ]
  if(item_ricevuti > 50 AND item_ricevuti <= 60)[
    set incr_preference 4
  ]
  if(item_ricevuti > 60 AND item_ricevuti <= 70)[
    set incr_preference 3
  ]
  if(item_ricevuti > 70 AND item_ricevuti <= 80)[
    set incr_preference 2
  ]
  if(item_ricevuti > 80 AND item_ricevuti <= 90)[
    set incr_preference 1
  ]
  if(item_ricevuti > 90 AND item_ricevuti <= 100)[
    set incr_preference 0
  ]
  ask character_x [
    set preference preference + incr_preference
  ]
end

to use_loot_sys
  ; defines  the LS according with the variable ls_in_use
  if(ls_in_use = 0)[
    rolling
  ]
  if(ls_in_use = 1)[
    karma
  ]
  if(ls_in_use = 2)[
    purelist
  ]
  if(ls_in_use = 3)[
    suicidekings
  ]
  if(ls_in_use = 4)[
    variable_dkp
  ]
  if(ls_in_use = 5)[
    fixed_dkp
  ]
  if(ls_in_use = 6)[
    auctiondkp
  ]
  if(ls_in_use = 7)[
    dkpzerosum
  ]
  if(ls_in_use = 8)[
    dkprelational
  ]
  if(ls_in_use = 9)[
    dualtoken
  ]
end

to rolling
  let perc_preference 0
  foreach group [
    ; if the item preference is lower than 10, the player does not roll the dice
    ; if the preference is between 10 and 40, the system perfoms the probability to roll a dice
    if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
      set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
      if (random 100 < perc_preference )[
        ask ? [
          set dice random 100
        ]
      ]
    ]
    ; if the preference is greater than 40, it roll a dice
    if(([preference] of ?) > 40)[
      ask ? [
        set dice random 100
      ]
    ]
  ]
  let counter 0
  foreach sort-by [[dice] of ?1 > [dice] of ?2] group [
    if (counter = 0 AND ([dice] of ? != 0))[
      set character_x ?
      ask ? [
        set present_pleasure  present_pleasure  + preference
        set count_item count_item + 1
        
        received_items_value
      ]
      set counter counter + 1
    ]
    ask ? [
      set dice 0
      set preference 0
      set counter counter + 1
    ]
  ]
end

to karma
  let perc_preference 0
  gain_karma
  foreach group [
    ; if the item preference is lower than 10, the player does not roll the dice
    ; if the preference is between 10 and 20, the system perfoms the probability to roll a dice
    if( (([preference] of ?) > 10) AND (([preference] of ?) <= 20) )[
      set perc_preference ( (([preference] of ?) - 10) * 100 / 10 )
      if (random 100 < perc_preference )[
        ask ? [
          set karma_dice random 100
        ]
      ]
    ]
    ; if the preference is between 20 and 40, the player roll a dice and it will perform the probability to 
    ; use karma bonus
    if( (([preference] of ?) > 20) AND (([preference] of ?) <= 40) )[
      set perc_preference ( (([preference] of ?) - 20) * 100 / 20 )
      ask ? [
        set karma_dice random 100
        
        if (random 100 < perc_preference )[
          set karma_dice karma_dice + karma_points
          set use_karma 1
        ]
      ]
    ]
    ; if it is bigger than 40, it always use its bonus
    if(([preference] of ?) > 40)[
      ask ? [
        set karma_dice random 100
        set karma_dice karma_dice + karma_points
        set use_karma 1
      ]
    ]
  ]
  let counter 0
  foreach sort-by [[karma_dice] of ?1 > [karma_dice] of ?2] group[
    if (counter = 0 AND ([karma_dice] of ? != 0))[
      set character_x ?
      ask ? [
        ;if the player uses the bonus and it wins the item, the bonus become 0
        if(use_karma = 1)[
          set karma_points 0
        ]
        set present_pleasure  present_pleasure  + preference
        set count_item count_item + 1
        received_items_value
      ]
      set counter counter + 1
    ]
    ask ? [
      set karma_dice 0
      set use_karma 0
      set preference 0
      set counter counter + 1
    ]
  ]
end

to received_items_value
  ; if the character get an item with a value bigger then its, the items value will added
  ; if the character does not have the item, its value is the same of the received item
  ; when the system perfom the item preference, if the character has a similar items with a greater ammount of value, the interest of the item drops down
  ask character_x[
    if (finded_item = "warrior_item00")[
      if (warrior_poss_value00 < item_value)[
        set warrior_poss_value00 item_value
      ]
    ]
    if (finded_item = "warrior_item01")[
      if (warrior_poss_value01 < item_value)[
        set warrior_poss_value01 item_value
      ]
    ]
    if (finded_item = "warrior_item02")[
      if (warrior_poss_value02 < item_value)[
        set warrior_poss_value02 item_value
      ]
    ]
    if (finded_item = "magician_item00")[
      if (magician_poss_value00 < item_value)[
        set magician_poss_value00 item_value
      ]
    ]
    if (finded_item = "magician_item01")[
      if (magician_poss_value01 < item_value)[
        set magician_poss_value01 item_value
      ]
    ]
    if (finded_item = "magician_item02")[
      if (magician_poss_value02 < item_value)[
        set magician_poss_value02 item_value
      ]
    ]
    if (finded_item = "priest_item00")[
      if (priest_poss_value00 < item_value)[
        set priest_poss_value00 item_value
      ]
    ]
    if (finded_item = "priest_item01")[
      if (priest_poss_value01 < item_value)[
        set priest_poss_value01 item_value
      ]
    ]
    if (finded_item = "priest_item02")[
      if (priest_poss_value02 < item_value)[
        set priest_poss_value02 item_value
      ]
    ]
    if (finded_item = "thief_item00")[
      if (thief_poss_value00 < item_value)[
        set thief_poss_value00 item_value
      ]
    ]
    if (finded_item = "thief_item01")[
      if (thief_poss_value01 < item_value)[
        set thief_poss_value01 item_value
      ]
    ]
    if (finded_item = "thief_item02")[
      if (thief_poss_value02 < item_value)[
        set thief_poss_value02 item_value
      ]
    ]
  ]
end
to gain_karma
  ; Poins that can be spend in karma ls, they can be gained based on certain aspects as:
  foreach group[
    ask ? [
      ; puntuality
      if (random 100 < 90)[
        set karma_points karma_points + 5
      ]
      ; companion replacement
      if (random 100 < 20)[
        set karma_points karma_points + 5
      ]
      ; finish a raid
      if (random 100 < 90)[
        set karma_points karma_points + 5
      ]
      ; defeat a boss
      ifelse ([class] of ? != "priest")[
        ; if the character is a priest, it has lower possibilities to kill a boss
        if (random 100 < 80)[
          set karma_points karma_points + 5
        ]
      ][
      if (random 100 < 40)[
        set karma_points karma_points + 5
      ]
      ]
    ]
  ]
end
to purelist
  let winner 0
  let counter 0
  foreach sort-by [[list_pos] of ?1 < [list_pos] of ?2] group[
    if (counter = 0)[
      set winner ([list_pos] of ?)
      set character_x ?
      ask ? [
        set present_pleasure  present_pleasure  + preference
        set count_item count_item + 1
        received_items_value
      ]
    ]
    ask ? [
      set preference 0
      set counter counter + 1
    ]
  ]
  foreach sort-by [[list_pos] of ?1 < [list_pos] of ?2] turtles[
    if (([list_pos] of ?) = winner)[
      ask ? [ set list_pos (count turtles)]
    ]
    if (([list_pos] of ?) > winner)[
      ask ? [ set list_pos list_pos - 1]
    ]
  ]
end

to suicidekings
  let get_item 0 ; 0 or 1, determine if the item was looted by a member of the group
  let perc_preference 0
  let winner 0 ; used to save the winner position in the list
  foreach sort-by [[list_pos] of ?1 < [list_pos] of ?2] group[
    if(get_item = 0)[ ; check if the item is not already dropped by someone
      
                      ; if the preference is lower then 10, the character does not get the item
                      ; if the preference is between 10 and 40, the system perform a probabilit to drop the item
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ ; la percentuale di prendere l'item
          set winner ([list_pos] of ?)
          set get_item 1
          set character_x ?
          ask ? [
            set present_pleasure  present_pleasure  + preference
            set count_item count_item + 1
            received_items_value
          ]
        ]
      ]
      ; if the preference is greater than 40, the character get the item
      if(([preference] of ?) > 40)[
        set winner ([list_pos] of ?)
        set get_item 1
        set character_x ?
        ask ? [
          set present_pleasure  present_pleasure  + preference
          set count_item count_item + 1
          received_items_value
        ]
      ]
    ]
    ask ? [
      set preference 0
    ]
  ]
  ; updating the player position
  foreach sort-by [[list_pos] of ?1 < [list_pos] of ?2] turtles[
    if (([list_pos] of ?) = winner)[
      ask ? [ set list_pos (count turtles)]
    ]
    if (([list_pos] of ?) > winner)[
      ask ? [ set list_pos list_pos - 1]
      
    ]
  ]
end

to get_dkp
  ; similar to the karma, it will used for dkp ls
  foreach group[
    ask ? [
      ; puntuality
      if ((random 100) < 90)[
        set dkp_points dkp_points + 5
      ]
      ; companion replacement
      if ((random 100) < 20)[
        set dkp_points dkp_points + 5
      ]
      ; finish a raid
      if ((random 100) < 90)[
        set dkp_points dkp_points + 5
      ]
      ; defeat a boss
      ifelse ([class] of ? != "priest")[
        ; if it is a priest, the probabilty to defeat a boss is lower
        if ((random 100) < 80)[
          set dkp_points dkp_points + 5
        ]
      ][
      if (random 100 < 40)[
        set dkp_points dkp_points + 5
      ]
      ]
    ]
  ]
end

to variable_dkp
  get_dkp
  let get_item 0 ; 0 or 1, it defines if a item is already taken in the group 
  let perc_preference 0
  foreach sort-by [[dkp_points] of ?1 > [dkp_points] of ?2] group[
    if(get_item = 0)[ ; check if the item was not already taken
      
      ;if the preferences of the item is lower than 10, the player does not get the item
      ; if the preference is between 10 and 40, the system perfom a random extractiont to check if the player get the item
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ 
          set get_item 1 
          
          set character_x ?
          ask ? [
            set dkp_points 0 ;if character wins the item, it lost all the dkp points
            set present_pleasure  present_pleasure  + preference
            set count_item count_item + 1
            received_items_value
          ]
        ]
      ]
      ; if the preferece is greater than 40, it get the item
      if(([preference] of ?) > 40)[
        set get_item 1
        set character_x ?
        ask ? [
          set dkp_points 0 ;if character wins the item, it lost all the dkp points
          set present_pleasure  present_pleasure  + preference
          set count_item count_item + 1
          received_items_value
        ]
      ]
    ]
    ask ? [
      set preference 0
    ]
  ]
end
to fixed_dkp
  get_dkp
  let get_item 0 ; 0 or 1, defines if a item was taken by a group member
  let perc_preference 0
  ; The price of a item is related to him value, a 0 level item ammout to 10 dkp, an 9 level item ammout to 100 dkp
  let item_price 0
  set item_price (item_value + 1) * 10
  foreach sort-by [[dkp_points] of ?1 > [dkp_points] of ?2] group[
    if(get_item = 0)[ ; checks if the item is not already taken
      
      ; if the preference is lower then 10, the character does not get the item
      ; if the preference is between 10 and 40, the system perform a probability to try to get the item 
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ ; probability to get the item
          set get_item 1 
          set character_x ?
          
          ask ? [
            set dkp_points (dkp_points - item_price) ;if the player get the item, the dkp is subtracted from the item cost
            set present_pleasure  present_pleasure  + preference
            set count_item count_item + 1
            received_items_value
          ]
        ]
      ]
      ; if the preference is greater than 40, it gets the item
      if(([preference] of ?) > 40)[
        set get_item 1
        set character_x ?
        ask ? [
          set dkp_points (dkp_points - item_price) 
          set present_pleasure  present_pleasure  + preference
          set count_item count_item + 1
          received_items_value
        ]
      ]
    ]
    ask ? [
      set preference 0
    ]
  ]
end

to auctiondkp
  let get_item 0 ; 0 or 1, defines if a item was taken by a group member
  let perc_preference 0
  let counter 0
  get_dkp
  foreach sort-by [[dkp_points] of ?1 > [dkp_points] of ?2] group[
     ; if the preference is lower then 10, the character does not get the item
     ; if the preference is between 10 and 40, the system perform a probability to try to get the item 
     if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
      set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
      if ((random 100) < perc_preference )[ ; probability to offer
        ask ? [
          ; the offers is 3 times greater then the item value
          set auction_offer (preference * 3)
          ;if the player does not have enough dkp, it goes all in
          if(auction_offer > dkp_points)[
            set auction_offer dkp_points
          ]
        ]
        
      ]
    ]
    ; if the preference is greater than 40, the players alway apply an offer
    if(([preference] of ?) > 40)[
      ask ? [
        set auction_offer (preference * 3)
        if(auction_offer > dkp_points)[
          set auction_offer dkp_points
        ]
      ]
    ]
  ]
  foreach sort-by [[auction_offer] of ?1 > [auction_offer] of ?2] group[
    if ((counter = 0) AND ([auction_offer] of ? != 0))[
      set character_x ?
      ask ? [
        set dkp_points (dkp_points - auction_offer) ;if the player gains the item, it lost the dkp offered
        set present_pleasure  present_pleasure  + preference
        set count_item count_item + 1
        received_items_value
      ]
    ]
    set counter counter + 1
    ask ? [
      set auction_offer 0
      set preference 0
    ]
  ]
end
to dkpzerosum
  let get_item 0 ; 0 or 1, it defines if a item was taken by a group member
  let perc_preference 0
  ; The price of a item is related to him value, a 0 level item ammout to 10 dkp, an 9 level item ammout to 100 dkp
  let item_price 0
  set item_price (item_value + 1) * 10
  foreach sort-by [[dkp_points] of ?1 > [dkp_points] of ?2] group[
    
    if(get_item = 0)[
        ; if the preference is lower then 10, the character does not get the item
        ; if the preference is between 10 and 40, the system perform a probability to try to get the item 
        if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ ; probability to get the item
          set get_item 1
          set character_x ?
          ask ? [
            set dkp_points (dkp_points - item_price) 
            set present_pleasure  present_pleasure  + preference
            set count_item count_item + 1
            received_items_value
          ]
        ]
      ]
      ; if the preference is greater than 40, the character get the item
      if(([preference] of ?) > 40)[
        set get_item 1
        set character_x ?
        ask ? [
          set dkp_points (dkp_points - item_price) ;if the players gets the item, it lost an amount equal to the cost
          set present_pleasure  present_pleasure  + preference
          set count_item count_item + 1
          received_items_value
        ]
      ]
    ]
    ask ? [
      set preference 0
    ]
  ]
  if (get_item = 1)[ ;if a player gets the item
    foreach group[
      ask ?[ set dkp_points dkp_points + int (item_price / length group) ;the other participants get a portion of dkp
      ]
    ]
  ]
end
to dkprelational
  get_dkp
  let get_item 0 ; 0 or 1, it defines if a item was taken by a group member
  let perc_preference 0
  ; The price of a item is related to him value, a 0 level item ammout to 10 dkp, an 9 level item ammout to 100 dkp
  let item_price 0
  
  set item_price (item_value + 1) * 10
  foreach sort-by [ ([dkp_points] of ?1) / ([spent_points] of ?1)> ([dkp_points] of ?2) / ([spent_points] of ?2)] group[
    if(get_item = 0)[ 
      ; if the preference is lower then 10, the character does not get the item
      ; if the preference is between 10 and 40, the system perform a probability to try to get the item 
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ 
          set get_item 1 
          set character_x ?
          ask ? [
            set spent_points (spent_points + item_price)
            set present_pleasure  present_pleasure  + preference
            set count_item count_item + 1
            received_items_value
          ]
        ]
      ]
      ; if the preference is greater than 40, the character get the item
      if(([preference] of ?) > 40)[
        set get_item 1
        set character_x ?
        ask ? [
          set spent_points (spent_points + item_price)
          set present_pleasure  present_pleasure  + preference
          set count_item count_item + 1
          received_items_value
        ]
      ]
    ]
    ask ? [
      set preference 0
    ]
  ]
end

to dualtoken
  let get_item 0 ; 0 or 1, it defines if a item was taken by a group member
  let perc_preference 0
  let need_list [ ]
  let greed_list [ ]
  foreach group[
    ;in order to use a need token the item class must be equal to the item class
    ifelse ((([need_token] of ?) != 0) AND
      ((([class] of ? = "warrior") AND
        (
          (finded_item = "warrior_item00") OR (finded_item = "warrior_item01") OR (finded_item =
            "warrior_item02")
            ))
        OR(([class] of ? = "magician") AND
          (
            (finded_item = "magician_item00") OR (finded_item = "magician_item01") OR (finded_item = "magician_item02")
            ))
        OR(([class] of ? = "priest") AND
          (
            (finded_item = "priest_item00") OR (finded_item = "priest_item01") OR (finded_item =
              "priest_item02")
            ))
        OR(([class] of ? = "thief") AND
          (
            (finded_item = "thief_item00") OR (finded_item = "thief_item01") OR (finded_item =
              "thief_item02")
            )))
      )
    [
      ; if the item preference is lower than 10, the player never use the token
      ; if the item preference is between 10 and 40, the system performs a probability to use the token
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ ; probability to get the item
          set need_list fput ? need_list
          ask ? [
          ]
        ]
      ]
      ; if the prefernce is greater than 40, the character use always the token
      if(([preference] of ?) > 40)[
        set need_list fput ? need_list
        ask ? [
        ]
      ]
    ][; otherwise it could use the greed token
    if (([greed_token] of ?) != 0)[
      ; if the item preference is lower than 10, the player never use the token
      ; if the item preference is between 10 and 40, the system performs a probability to use the token
      if( (([preference] of ?) > 10) AND (([preference] of ?) <= 40) )[
        set perc_preference ( (([preference] of ?) - 10) * 100 / 30 )
        if ((random 100) < perc_preference )[ 
          set greed_list fput ? greed_list
          
          ask ? [
          ]
        ]
      ]
     ; if the preference is greater than 40, the character use always the greed token
       if(([preference] of ?) > 40)[
        set greed_list fput ? greed_list
        ask ? [
        ]
      ]
    ]
    ]
  ]
  ifelse(length need_list != 0)[
    ;if nobody get the token, a random agent of the group was selected
    set character_x one-of need_list
    ask character_x[
      set get_item 1
      set need_token need_token - 1 ;if the player get the item, it loses its token
      set present_pleasure  present_pleasure  + preference
      set count_item count_item + 1
      received_items_value
    ]
  ][
  ;if there is no need token, use the greed
  if(length greed_list != 0)[
    set character_x one-of greed_list
    ask character_x[
      set get_item 1
      set greed_token greed_token - 1 
      set present_pleasure  present_pleasure  + preference
      set count_item count_item + 1
      received_items_value
    ]
  ]
  ]
  if(get_item = 0)[
    ;if all the lists are empty, the item was randomly assigned
    set character_x one-of group
    ask character_x[
      set get_item 1
      set present_pleasure  present_pleasure  + preference
      set count_item count_item + 1
       received_items_value
    ]
  ]
  foreach group[
    ask ? [
      set preference 0
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
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
0
0
1
ticks

BUTTON
848
174
911
207
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

BUTTON
706
208
769
241
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

@#$#@#$#@

# 5.1 SECONDMMOSIMULATION

## WHAT IS IT?

It consider the whole MMO world from the point of view of the game designer, the information that can be derived from the previous simulation is clearly insufficient. 
As a matter of fact, the goals of the company managing the game are to maximize both the number of (paying) players and their satisfaction; hence, the vision of a single individual is not enough.
Players belonging to a specific category share common behavioural traits; hence, their relative number may influence heavily the general climate of a specific world, and – possibly – its success or failure.
In this framework, our goal is to verify if the choice of a specific LS can influence – and to what extent – the balance among player types.

## GETTING STARTED

In order to use the software you will download the NetLogo enviroment from https://ccl.northwestern.edu/netlogo/ (ver. 4.1.3) and open the "SecondMMOSimulation.nlogo" file with the NetLogo IDE.
The software was tested under a Window 10 machine; anyway, it should also work on different OS. 

## HOW IT WORKS AND HOW TO USE IT

The simulation parameters can be modified changing the variables inside the code under the function "setup".

The parameters are:
 * "ls_in_use" it acept an integer value [0-9] where: 0 Rolling; 1 Karma; 2 Pure List; 3 Suicide Kings; 4 DKP with variable prices; 5 DKP with fixed prices; 6 DKP wit auction; 7 DKP Zero-Sum; 8 DKP Relational; 9 Dual Token
 * "tax" 0 or 1, for the Karma system and DKP systems, it indicates whether agents' points are periodically taxed
 * "mission_num_items": indicates the number of items that can be found in each mission
 * dominant_typology "bartle-type1": define the dominant typology, replace the string bartle-type1 with one of "killer", "explorer", "socializer", or "achiever"
 * remaining_typology_list ["bartle-type2" "bartle-type3" "bartle-type4"]: define the others type of player available in the world
 * perc_dominant_typology: defines the percentage of player of dominance typology
 * population: intger value that defines the total population
  

## THINGS TO NOTICE

The output is not automatically printed out. It is cointained in the variables:

 * socializer_list
 * explorer_list
 * achiever_list
 * killer_list

The software was developed and tested using NetLogo 4.1.3

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

Journal Paper

Conference Papers
 * De Felice D., Granato M., Ripamonti L.A., Trubian M., Gadia D., Maggiorini D. (2017). Effect of different Looting Systems on the behavior of players in a MMOG: simulation with real data, Springer Lecture Notes of the Institute for Computer Sciences, Social Informatics and Telecommunications Engineering (Proceedings of EAI International Conference on Games fOr WELL-being - GOWELL - Revised Selected Papers) 181, pp. 110-118.
 * Maggiorini D., Nigro A., Ripamonti L.A., and Trubian M. (2012). Massive Online Games and Loot Distribution: an Elusive Problem, in Proc. SIMUTools 2012, 5th International ICST Conference on Simulation Tools and Techniques, Desenzano del Garda, Italy, March 19 - 23, 2012, pag. 226-233 ISBN: 978-1-4503-1510-4, DOI 10.4108/icts.simutools.2012.247777.
 * Maggiorini D., Nigro A., Ripamonti L.A., and Trubian M. (2012). Loot distribution in massive online games: Foreseeing impacts on the players base. In 2012 21st International Conference on Computer Communications and Networks (ICCCN), pages 1-5. IEEE.
 * Maggiorini D., Nigro A., Ripamonti L.A., and Trubian M. (2012). The Perfect Looting System: Looking for a Phoenix?, Computational Intelligence and Games (CIG) 2012 IEEE Conference on, pp. 371-378.

## LICENSE

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: "Multi-Agent Simulations for the Evaluation of Looting Systems Design in MMO Games".

If you are writing a scientific paper you could also give attribution by citing the papers presented in Section HOW TO CITE
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
NetLogo 4.1.3
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
