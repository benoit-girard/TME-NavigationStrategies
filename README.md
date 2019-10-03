# TME-NavigationStrategies

## Contexte

Ce TME requiert l'installation de [pyfastsim](https://github.com/alexendy/pyfastsim), une interface python du simulateur très léger [fastsim](https://github.com/jbmouret/libfastsim).

C'est un complément des cours sur les stratégies multiples de navigation et sur l'apprentissage par renforcement.

## Présentation générale

L’objectif de ce TME est de tester plusieurs méthodes de coordination de stratégies de navigation pour un robot doté de deux stratégies simples, en quantifiant leur efficacité dans un environnement où la coopération de ces stratégies est nécessaire.

Deux stratégies de navigation sont pré-programmées : 
* Un suivi de mur (wallFollower.py) qui maintient le robot à distance des murs (trop près, il s'en éloigne, trop loin il s'en rapproche), tourne sur lui-même à la recherche d'un mur s'il n'y en a pas à proximité, ou s'il a un obstacle devant lui.
* Une approche de balise (radarGuidance.py) qui oriente le robot vers une balise dont la direction est fournie.

Elles sont testables de manière isolée en lançant ```python wallFollower.py``` et ```python radarGuidance.py```. La coordination des deux stratégies est à coder dans ```strategyGating.py```, qui contient déjà le code permettant de lancer la simulation, de récupérer les données des senseurs, de les transformer en un identifiant d'état (voir plus loin), de téléporter le robot lorsqu'il arrive au but (et de le récompenser), de le punir lorsqu'il approche trop d'un mur, et de répéter les opérations jusqu'à l'obtention de 40 récompenses.

## Informations techniques

Vous allez devoir ajouter du code dans la fonction ```strategyGating``` du fichier ```strategyGating.py``` pour coder les méthodes d'arbitrage proposées en exercice, et aussi probablement du code pour enregistrer des données en fin d'expérience, à la fin de la fonction ```main``` de ce même fichier.

Lorsqu'une expérience est menée à terme (jusqu'à atteindre ```nbTrials```), la durée de chaque essai est enregistrée dans un fichier de la forme ```log/time-TrialDuration-methode.txt ```. 

## Description du problème

![Arène](entonnoir2.png)

L’environnement utilisé est composé d’une arène carrée (600x600 pixels) comprenant un obstacle, et un but. Ce but est de type goal dans fastsim, ce qui veut dire qu’il s’agit d’une balise dont la direction peut être détectée par un senseur de type radar, même à travers les murs.

Le robot est équipé des capteurs suivants :
— un télémètre laser de 200 degrés d’ouverture, fournissant une mesure de distance tous les degrés,
— des détecteurs de contact droite et gauche,
— un radar capable de détecter la direction du but dans l’un des 8 secteurs autour du robot,
- un capteur grossier de distance de la balise (0 : proche, 1 : moyenne, 2 : éloignée) est simulé à partir de la position du robot produite par le simulateur, elle est utilisée dans la définition d'état pour l'apprentissage.

Le robot démarre toujours la simulation à la position (300,35).

L’obstacle en forme de U fait qu’un robot utilisant la stratégie d’approche de balise seule va y rester coincé.
De la même façon, la stratégie de suivi de mur va soit faire tourner le robot autour de l’arène, soit autour de l’obstacle, sans lui permettre d’atteindre le but. Il va donc être nécessaire de coordonner l’usage de ces deux stratégies afin de résoudre la tâche dans un temps raisonnable.

```strategyGating.py``` est conçu pour que, par défaut, lorsque le robot atteint le but, il soit téléporté à son point de départ. Cette téléportation marque la fin d’un « essai » (trial), le programme s’arrête de lui-même lorsque ce nombre d’essais atteint la valeur nbTrials (40), que vous pouvez donc modifier selon vos besoins. Chaque fois que le robot atteint le but la variable de récompense ```rew``` passe à 1 et chaque fois qu’il percute un mur, elle passe à -1. **C’est à la méthode d’arbitrage (que vous allez programmer) de remettre cette valeur à 0 lorsque l’information a été traitée.**

## Exercices

Prévoyez de m’envoyer par mail à la fin du TME votre code de ```strategyGating.py```, les fichiers de log contenant les informations demandées (durées des essais, Q valeurs), ainsi qu'un pdf de vos réponses aux questions, en me rappelant la composition de votre binôme.

1. Vous pouvez constater en lançant un arbitrage de type ```random``` qu’un choix uniforme à chaque pas de temps de l’une des deux stratégies n’a pratiquement aucune chance de sortir le robot du cul-de-sac. Ecrivez une première méthode d’arbitrage ```randomPersist``` choisissant l’une des deux stratégies avec la même probabilité, mais persistant dans son choix pendant deux secondes. Cette stabilité accrue dans les choix devrait permettre au robot d’avoir une réelle chance de sortir du cul-de-sac.

2. Effectuez 20 essais avec cette nouvelle stratégie, gardez de côté le fichier ```XXX-TrialDurations-YYY``` qui contient le temps nécessaire à chaque essai pour atteindre le but. Calculez la médiane, les premier et troisième quartiles de ces temps. Ces données vont nous servir de référence: toute méthode *intelligente* devra essayer de faire mieux que cette approche aveugle. *Vous pouvez, pour cela, utiliser la fonction « percentile » de numpy.*  
**Pro-tip :** Pendant que ça tourne, plutôt que de vous laisser hypnotiser par le robot qui bouge, attaquez la question suivante : vous avez un temps limité...

3. Implémentez une méthode d'arbitrage ```qlearning``` similaire à celle utilisée par (Dollé et al., 2010) : elle utilise un algorithme de Q Learning pour apprendre, essai après essai, quelle est la meilleure stratégie à choisir en fonction de l’état du monde.
**Définition des états :** On travaille ici avec une approche tabulaire, les états sont discrets, ils on un identifiant qui est une chaîne de caractère construite de la manière suivante (voir figure): les trois premiers caractères (0 ou 1) indiquent s'il y a un mur à proximité à gauche, au milieu, à droite ; le caractère suivant, entre 0 et 7, indique la direction de la balise ; le dernier (0, 1 ou 2) indique si la balise est proche (<125 pixels), moyennement éloignée (<250 pixels), ou lointaine (>= 250 pixels). Ces états sont déjà construits (par la fonction ```buildStateFromSensors```), l'état courant est lisible dans ```S_t```, l'état précédent dans ```S_tm1```.
**Q-Learning :**
