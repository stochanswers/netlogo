extensions [array]
globals [reproduction-number old-infected new-infected]

breed [individuals individual]
individuals-own [
  state                   ;; my current state: "INFECTED", "RECOVERED", or "SUSCEPTIBLE"
  marked?                 ;; whether I'm currently marked
]

to setup
  clear-all
  ;; set up the model
  make-turtles
  set reproduction-number basic-reproduction-number
  set new-infected 1
  recolor
  reset-ticks
end

;; create all the turtles, place them, and associate forks with individuals
to make-turtles
  set-default-shape individuals "person torso"
  ;; create-ordered-<breed> equally spaces the headings of the turtles,
  ;; in who number order
  create-ordered-individuals population [
    set size 0.1
    jump 0.35
    set state "SUSCEPTIBLE"
    set marked? false
  ]
  ask individual 0 [set state "INFECTED"]
  if prior-immunity-proportion > 0 [
    let index 1
    repeat prior-immunity-proportion * population [
      ask individual index [set state "RECOVERED"]
      set index (index + 1)
      if index >= population [ stop ]
    ]
  ]
end

to go
  if new-infected > 0
  [
    a-go
  ]
end

to a-go
  set old-infected new-infected
  clear-links
  ask individuals [ infect ]
  set new-infected 0
  ask individuals [ update ]
  ifelse old-infected = 0
  [
    set reproduction-number 0
  ]
  [
    set reproduction-number (new-infected / old-infected)
  ]
  recolor
  tick
end

;; everybody gets a new color.
to recolor
  ask individuals [
    ;; look up the color in the colors list indexed by our current state
    ifelse state = "SUSCEPTIBLE"
      [ set color blue ]
      [ ifelse state = "INFECTED"
        [ set color red ]
        [ set color green ] ]
  ]
end

;;
to infect  ;; individual procedure
  if state = "INFECTED" [
    ;; create an array of random numbers
    let values array:from-list shuffle range (population - 1)
    let index 0
    repeat basic-reproduction-number [
      let i2 array:item values index
      let i3 ((i2 + 1 + who) mod population)
      ask individual i3 [set marked? true]
      create-link-with individual i3
      set index (index + 1)
    ]
  ]
end

;;
to update  ;; individual procedure
  if state = "INFECTED" [
    set state "RECOVERED"
  ]
  if marked? and state = "SUSCEPTIBLE"
  [
    set state "INFECTED"
    set new-infected (new-infected + 1)
  ]
  set marked? false
end


; Copyright 2003 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
354
10
762
419
-1
-1
400.0
1
10
1
1
1
0
0
0
1
0
0
0
0
1
1
1
ticks
30.0

BUTTON
10
139
78
172
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
85
139
154
172
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
10
30
183
63
population
population
15
40
31.0
1
1
NIL
HORIZONTAL

PLOT
10
179
345
418
Compartments
Time
Individuals
0.0
2.0
0.0
100.0
true
true
"set-plot-y-range 0 (count individuals)" ""
PENS
"Susceptible" 1.0 0 -13345367 true "" "plot count individuals with [state = \"SUSCEPTIBLE\"]"
"Infected" 1.0 0 -2674135 true "" "plot count individuals with [state = \"INFECTED\"]"
"Recovered" 1.0 0 -10899396 true "" "plot count individuals with [state = \"RECOVERED\"]"

BUTTON
160
139
235
172
go once
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
10
66
230
99
prior-immunity-proportion
prior-immunity-proportion
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
10
102
241
135
basic-reproduction-number
basic-reproduction-number
2
5
2.0
1
1
NIL
HORIZONTAL

PLOT
10
426
262
622
Reproduction number
Time
Number
0.0
2.0
0.0
5.0
true
false
"set-plot-y-range 0 reproduction-number" ""
PENS
"default" 1.0 0 -16777216 true "" "plot reproduction-number"

PLOT
503
426
762
622
Ternary plot
Susceptible
Recovered
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 (count individuals)\nset-plot-y-range 0 (count individuals)\nset-current-plot-pen \"pen-1\"\nplotxy 0 (count individuals)\nplotxy (count individuals) 0\nplotxy 0 0\nplotxy 0 (count individuals)" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy count individuals with [state = \"SUSCEPTIBLE\"] count individuals with [state = \"RECOVERED\"]"
"pen-1" 1.0 0 -5298144 true "" ""

@#$#@#$#@
## WHAT IS IT?

The Minimal SIR model is a compartmental model of an epidemic that averages to the standard SIR model (Kermack-McKendrick, 1927). Each individual within a population is in one of three states known, in epidemic modelling, as compartments: 

* S - Susceptible to infection.
* I - Infected and infectious.
* R - Recovered and immune to re-infection.

## HOW IT WORKS

### Setup

There are sliders to vary:

* The size of the population that will be divided into compartments.
* The proportion of the population that has prior immunity.
* The  basic reproduction number.

The basic reproduction number, R0, is defined as the number of individuals that will be infected by one individual in an otherwise susceptible population.

### Go

Initially one individual is infected. At each step the simulation proceeds by each
infected individual selecting R0 others at random and irrespective of their state. At
the end of the step the infected become recovered and those susceptible that were selected become infected. The simulation finishes when there are no longer any infected.

As the simulation progresses lines are drawn between the previous generation of infected and those individuals that they were in contact with. The colour of the individuals changes according to the code:

* Susceptible - Blue.
* Infected - Red.
* Recovered - Green.

There are two plots of how the statistics vary as the iterations proceed. The first shows how the individuals are divided between the three compartments. The second how the reproduction number varies between zero and R0.

## HOW TO USE IT

Move the sliders then press setup. Perform a simulation and note how the epidemic curves vary.


## THINGS TO NOTICE

### Ternary plot

Since the sum of the number of individuals in the three compartments is constant they can be plotted within a triangle. Note that the diagonal axis corresponds to the number of infected being zero.

### Herd immunity

At the end of a simulation some individuals may still be susceptible. This is because of an effect known as herd immunity. Note that they are not immune and a subsequent outbreak could occur. To demonstrate this re-run with more prior immunity.

### Variation of the reproduction number

If this were constant then the epidemic would be growing exponentially. If this were the standard SIR model instead then it would be a smoothly decreasing function. For no prior immunity the initial step plots a value of R0 which matches its definition. Note that, in general, this does not decrease with time.

### Selecting R0 others

Each infected picking the number of susceptible is equivalent to sampling (without replacement) R0 individuals from a hypergeometric probability distribution.

### Matching exponential growth

Requires that only susceptible are picked. The probability of that happening can then be
calculated by forming a fraction where the numerator is the numbers from the size of the population down to one all multiplied together and the denominator is the number of choices multiplied together. e.g. 31 x 30 x 29 x 28 x ... x 1 divided by 31 x 30 x 29 x 30 ... x 29 for a population of 31, no prior immunity and R0 equal to 2.


## THINGS TO TRY

### Average behaviour

If you are prepared to alter the code then scale the population to, say, 1000 individuals and run numerous times to create an ensemble of results at each step which are then averaged. Calculate the rate of change of the number of susceptible with respect to the number of recovered. Show that this matches the logistic growth of the standard SIR model.

### Epidemiological tag

Take a group of children, tell them that when they are first tagged they are to tag two others. Choose the first one then see whether, at the end of the game, they can be lined up in columns corresponding to generations of the epidemic.

### Epidemic, the card game

Take two packs of playing cards, cut them both down to the same 31 cards. One will be used to shuffle and deal from, the other to track the states. A column of cards is formed by considering all the cards in the previous column. For each of those cards remove the corresponding card from the shuffle, shuffle then deal two cards. If that is the first time that a card has been dealt then add the corresponding card to the new column. Return all three cards to the pack for the next shuffle, if you don't then you'll get exponential growth.


## EXTENDING THE MODEL

### Social networks

In this model each individual has equal chance to infect every other. i.e. The population forms a complete graph. Extending to a sparse graph, specifically a social network, provides a better model. When performed on a network formed by voles the resultant ensemble average behaviour compared to a complete graph showed a lower number of infections and a greater number of steps. The reader might like to think of what this means in the contexts of lockdowns and of seasons.

### Stochastic calculus

Repeated application of the hypergeometric distribution can be approximated by using a logit-normal distribution for the ratio of the reproduction number to the basic reproduction number.


## CREDITS AND REFERENCES

This software implementation was forked from

* Wilensky, U. (2003).  NetLogo Dining Philosophers model.  http://ccl.northwestern.edu/netlogo/models/DiningPhilosophers.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Copyright 2003 Uri Wilensky.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:
* Mason, Z. W. T. (2025). The minimal SIR model, validated then extended to social networks and stochastic differential equations. https://osf.io/y6ckv/. StochAnswers Ltd, Sheffield, UK.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2025 Zebedee Mason

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

<!-- 2003 -->
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

fork
true
0
Polygon -7500403 true true 160 247 150 251 140 248 147 107 129 97 133 29 137 86 141 86 147 38 151 86 155 84 159 39 166 96 154 105

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

person torso
true
0
Circle -7500403 true true 106 17 88
Polygon -7500403 true true 140 95 141 115 97 125 63 222 57 232 57 248 67 250 75 245 77 237 111 174 120 257 182 257 192 175 225 241 227 248 235 251 239 251 248 242 243 231 239 232 206 126 163 114 161 92

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
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
