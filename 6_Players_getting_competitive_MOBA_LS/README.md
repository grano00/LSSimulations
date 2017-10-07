# MOBASimulation

## WHAT IS IT?

It is a simulation in order to investigate the player satisfaction under the Looting System (LS) of the most diffuse MOBA game, i.e. League of Legend (LoL).
It is also a pioneer in introducing LSs. For these reasons, we have decided to use LoL as a case study to verify to what extent the presence of an “official” LS, managed by the company producing the game, can increase the satisfaction of players, as any valid rewarding system. To increase the reliability of our findings, we have decided to base the structure of our simulation on real data, both quantitative and qualitative. For this purpose, we have interviewed a group of LoL players, both from Italy and Finland; also, we asked LoL’s player to answer an online survey. Starting from the data collected, we have set up this simulation aimed at measuring how much their satisfaction with the game is influenced by the LS. 

## GETTING STARTED

In order to use the software you will download the NetLogo enviroment from https://ccl.northwestern.edu/netlogo/ and open the "MOBASimulation.nlogo" file with the NetLogo IDE.
The software was tested under a Window 10 machine; anyway, it should also work on different OS. 

## HOW IT WORKS AND HOW TO USE IT

The parameters of the simaulation are already setted with the survey parameter.
Anyway, almost all parameter can be modified in the interface tab.

Thus, the enviroment can be consider plug and play. To use it with the default paramenter, the user should click on setup button and, after that, the go button.

Anyway, in the interface tab, the user can modify these parameters:

 * "my-seed" and "my-random-seed": If my random seed is setted to off, the enviroment use seed described in "my-seed" in order to allow the simulation reproducibility;
 * "number-of-days": defines the simulation length. If "the defined-number-of-days" is setted to off, the simulation proceeds infinitely;
 * The "*-number" and "n-*" input window defines the agent topology distribution;
 * The "number-starting-char" defines the number of starting characters of each agent;
 * "max-friends-list" defines the maximum number of frieds for a single agent;
 * "friend-probability" defines the probability after a winning to add a member to a friend list (if the player loses the probability is lower);
 * "play-with-friend-prob" defines the probabilty to insert a friend in agent team
 * "p-casual/mid/hardcore" input monitors define the probability to involve the agent in a match;
 * The bottom-left input monitors define the satisfaction values regarding the LS;
 * The input monitors with "*-win" define the probability of each agent to help the team to winning the match;
 * The "ward-number" and "icon-number" define the number of favorite item (randomly generated) of, respectively, wards and icons.

Lastly, the plot area on the bottom visualize the satisfaction graph. It can be exported in a ".csv" file using the contextual menu.


## THINGS TO NOTICE

The enviroment uses the text output consiedring the point of view of turtle-to-follow.
The software was developed and tested using NetLogo 6.0.1

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





