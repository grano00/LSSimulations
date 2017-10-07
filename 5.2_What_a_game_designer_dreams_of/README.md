# 5.1 SecondMMOSimulation

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



