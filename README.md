# AoC2024
Advent of Code 2024 in ABAP and JAVA.

This years Advent of Code I'm going to resolve mostly in [ABAP](https://en.wikipedia.org/wiki/ABAP).

ABAP is probably not the most suitable language for this purpose, but non the less.

In case a puzzle beeing to tedious for ABAP I can switch java, e.g. if data structures like `Set` or `Map` will be needed and there is no simple way to replace them with ABAP tables. I'm very curious if this will happen.

![Resume Screenshot](images/Screenshot%20From%202025-01-11%2009-07-20.png)

Days in `ABAP`: 20
 
Days in `JAVA`: 4

Days in `python`: 1

## General remarks

I'm going to check in my solution code in this repository one day after the respective puzzle is unlocked complying to the terms (https://adventofcode.com/2024/about).

The ABAP solution will contain only the sourcecode of the solution class. If you want to try it you will have to copy paste the class into your own system and maybe use my little AOC Framework.

## Preparation

since I don't have access to an ABAP System at the moment I'm going to install one locally on my laptop.

I'm opting for an installation of a so called *miniSAP* in a docker container.

I found a really good description on how to create a *miniSAP* System in Docker here: [SAP NW ABAP Trial in Docker by Brandon Caulfield](https://github.com/brandoncaulfield/sap-nw-abap-trial-docker-windows).

## Development environment

I'm goining to mostly work with the eclipse based deveopment environment ADT (Abap Development Toolkit).

![ADT Screenshot](images/Screenshot%20From%202024-11-30%2011-48-05.png)

If you are using SAP you can't get past SAPGUI, especially transaktion SE80
![SE80](images/Screenshot%20From%202024-11-30%2011-49-10.png)

## Framework

To be able to resolve a puzzle of AoC you need to be able to process the a puzzle input an put the result into the result filed of the respective puzzle.

The puzzle input is an ascii text, consisting of multiple lines. The text may be really big. AoC also provides some small test cases. 

Thus all you need is a method to upload the puzzles text as input to your solution code.

I decided to create a litte frame work where i can use a browser to upload the puzzle.

### Implementation of the Frameowrk

#### Web Page

To keep the things as simple as possible I'm going to write a simple [`bsp`](https://help.sap.com/doc/saphelp_snc700_ehp01/7.0.1/en-US/5a/f8b53a364e0e5fe10000000a11405a/content.htm?no_cache=true) Page.

`bsp` (Business Service Pages) is a web technology from the 90'ties, just like jsp or asp to create server based web pages. There are more sophisticated ways to to this in SAP but I like `bsp` because of its simplicity.

Finally the `bsp` page will look like this (using [picocss](https://picocss.com))

![AoC2024 Testpage](images/Screenshot%20From%202024-11-30%2011-19-13.png)

#### Preparing the ICF (Internet Connection Server)
To be able to use `bsp` you will have to prepare your freshly installed *miniSAP*. Go to the transacation `SICF` and activate all `bsp` related nodes. Either you read the [SAP Documentation](https://help.sap.com/doc/saphelp_snc700_ehp01/7.0.1/en-US/78/9852aec06b11d4ad310000e83539c3/frameset.htm) or you go on with try and error. The SAP error messages will guide you.

#### The `bsp` coding

see [abap/bsp/index.html](abap/bsp/index.html) and [abap/bsp/handler](abap/bsp/index.html.handlers.abap)

The `bsp` creates an instance of a solution class. This instance has to implement the `ZIF_AOC` interface.

see: [zif_AOC2024](abap/zif_aoc2024.abap)

#### The base class

It turns out, that there are some tasks as splitting the input into single lines, that will be needed in all puzzles. So I decided to implement them in a base class which is going to be the base for all puzzle implementation.

see [abap/zcl_aoc2024_base.abap](abap/zclaoc2024_base)

#### Puzzle implementation

To implement a puzzle solution I only have to subclass the `zclaoc2024_base` and implement the `resolve` method. `resolve` takes one input parameter `puzzleinput` of type `string` and returns `string` (via `result` return variable).

## Daily solutions

### Day 1

puzzle for [day1](https://adventofcode.com/2024/day/1)

duration: `1:32h`

percived difficulty: *easy*

solution in : [abap/claoc2024_day1](abap/zclaoc2024_day1.abap)

screencast: [Screencast Day 1](https://youtu.be/PQB9Fog-QUo)

##### Observations:

+ the `find regexp` command in abap is very powerful. 
+ using sorted tables is kind of clumsy, i still miss arrays, but it works none the less.
+ mixing old an new abap syntax is confusing, the compiler is not very strong.
+ have to look up the `reduce` and `for` statements which I've found accidentally see [ABAP help](https://help.sap.com/doc/abapdocu_752_index_htm/7.52/en-US/abenconstructor_expression_reduce.htm)


### Day 2

puzzle for [day2](https://adventofcode.com/2024/day/2)

duration Part 1: `1:25h`
duration Part 2: `0:30h`

percived difficulty: *easy*

solution in : [abap/claoc2024_day2](abap/zclaoc2024_day2.abap)

screencast: [Screencast Day 2 Part 1](https://youtu.be/drqAA8Wp69M)
 [Part 2](https://youtu.be/gl_JdLxo2X4) 

 Part 2 also consist of refactoring of Part 1 and fixing a problem with my testing web page.

##### Observations:

+ the `for ...in...` command in abap is very powerful, reminds of the generators in python in this solution it works just like `map`. The syntax is convoulted as usual in abap, lost lots of time reading and rereading the abap help. 
+ have to look up the `reduce` and `for` in more detail, seem very promissing.
+ the part 2 of the puzzle reuses parts of part 1, should think of it aready while writing part 1.

### Day 3

duration part 1: `0:38`
duration part 2: `0:32`

perceived difficulty: *easy*

solution in: [Solution Day 3](abap/zclaoc2004_day3.abap)

##### Observations:

+ until now, good knowlege of regular expressions is very helpful,.., like in real life
+ used the `reduce` statement. works very fine. strongly recommended if you want to calculate aggregations over tables (arrays).
+ don't need to split the input in lines when using regular expressions to parse :-)

### Day 4

duration part 1: `2:40:00`
duration part 2: `1:19:00`

perceived difficulty: *easy*
but only if I took the right appraoch from the beginning :-).

solution in:
[Implementation of a simple Matrix class](abap/zclaoc2024_day4_matrix.abap)
[Solution Day 4 Part 1](abap/zclaoc2024_day4part1.abap)
[Solution Day 4 Part 2](abap/zclaoc2024_day4part2.abap)

##### Observations:

+ lost lots of time on a worng approach/idea
+ the approach I took than turned out really usefull for part 2
+ in part 1, i struggled with the 1-based arrays/tables of abap, had some one-off errors, but thanks to the debugger...
3. in part 2 i struggled with the convoluted abap syntax, is there really no syntax variant for type `c length 1` like `c(1)`?

### Day 5

duration part 1: `1:45:00`
duration part 2: `2:20:00`

perceived difficulty: *middle*

nonetheless took me a lot of time....
we I haven't the (bubble) sort association from the beginning?

solution in:
[Solution Day 5 Part 1](abap/zclaoc2024_day5part1.abap)
[Solution Day 5 Part 2](abap/zclaoc2024_day5part2.abap)

##### Observations:
+ lost a bunch of time not knowing how my own `split_into_lines` method works

+ I again entered a wrong path following the first Idea I had. Maybe I should think more out of the box. in this case e.g. on order = sorting.

### Day 6

duration part 1: `2:08:00`
duration part 2: `5:00:00` maybe even more

perceived difficulty Part 1: *easy*
perceived difficulty Part 2: *to hard*

nonetheless took me a lot of time....

##### Observations:
+ lots of cases to cover
+ almost gave up, but finally succeded

solution in:
[Solution Day 6 Part 1](abap/zclaoc2024_day6part1.abap)
[Solution Day 6 Part 2](abap/zclaoc2024_day6part2.abap)


### Day 7

duration part 1: `2:05:00` for the first failed solution
duration part 1: additional `0:05:00` for the corrections.
duration part 2: `` maybe even more

perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *easy*


##### Observations
+ recursive decent / backtracking / breadth first solution feasible in ABAP, surprisingly good!
+ think simple, don't be tempted to build in premature optimizations without having completly understood the algorithm...
+ Part 2 was unexpecantly simple. 

solution in:
[Solution Day 7 Part 1](abap/zclaoc2024_day7part1.abap)
[Solution Day 7 Part 2](abap/zclaoc2024_day7part2.abap)


### Day 8

duration part 1: `1:52:00` for the first failed solution
duration part 1: additional `0:50:00` for the corrections.
duration part 2: until docker restart ``
duration part 2 after restart of docker: `0:16:00`

perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *easy*


##### Observations
+ there was an errror in my base class in the regular expression for splitting the puzzle in lines. \z and \a don't mean end and beginning of line - stupid.
+ first time I had problems undestanding the puzzle text exactly. what unique in the exaple realy means is not obvious for me looking at the examples and the text.
+ same like Part1, thera subletties in the description I didn't get on first read. Have to read more dilligently.

solution in:
[Solution Day 8 Part 1](abap/zclaoc2024_day8part1.abap)
[Solution Day 8 Part 2](abap/zclaoc2024_day8part2.abap)

### Day 09

duration part 1: `1:00:00` <br/>
duration part 2: `8:00:00` I've been struggeling with this.  

perceived difficulty Part 1: *easy*
perceived difficulty Part 2: *extra hard*

solution in:
[Solution Day 09](abap/zclaoc2024_day09.abap)

##### Observations
+ the key to reslove this was an appropriate data structure.
+ i tried an implementation using doubly linked list in ABAP. Horror with APAB Pointer costed me lots of time until i gave in.
+ for me this was the hardest until now.

### Day 10

duration part 1 and 2: `2:00:00` perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *easy*

solution in:
[Solution Day 10](abap/zclaoc2024_day10.abap)


### Day 11

duration part 1 and 2: `2:00:00` perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *middle*

solution in:
[Solution Day 11](abap/zclaoc2024_day11.abap)


##### Observations
+ another puzzle which could be solved using recursion 
+ this time recursion is supported by memoizations
+ brute force using batch job on the solution of part 1 was not successcfull because the memory on my docker SAP System run out of space.

### Day 12

duration part 1: `3:00:00`
duration part 2: `1:04:00`
perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *complex*

solution in:
[Solution Day 12](abap/zclaoc2024_day12.abap)

##### Observations
+ another puzzle which could be solved using recursion (walk_the_area method for Part 1)
+ I struggle sometimes with ABAPs verbousity, the code is really long.
+ I had done one mistake on the beginning, defining up/down/left/right function to access the respective patches...this let to lots of copy paste...should have refactored earlier
+ Part 2 Altgorithm I chose, turned out more complicated I expected, walking around may have been easiere.

### Day 13

duration part 1: `1:10:00`
duration part 2: `1:20:00`
perceived difficulty Part 1: *easy* with brute force
perceived difficulty Part 2: *easy* if you can see the obvious!

solution in:
[Solution Day 13 Part 1](abap/zclaoc2024_day13part1.abap)
[Solution Day 13 Part 2](abap/zclaoc2024_day13part2.abap)

##### Observations
+ again, I haven't see the obvious in part 1.... write the task in a proper way so you see
+ some math (linear algebra in this case) saves a lot of code and CPU
+ I should repeat how to solve linear equations.

### Day 14

duration part 1: `2:10:00`
duration part 2: `1:47:00`
perceived difficulty Part 1: *easy* 
perceived difficulty Part 2: *middle* 

solution in:
[Solution Day 14 Part 1](abap/zclaoc2024_day14part1.abap)
[Solution Day 14 Part 2](abap/zclaoc2024_day14part2.abap)
[Christmas Tree](christmas_tree.txt)

##### Observations
+ again, I haven't see the obvious in part 1.... write the task in a proper way so you see
+ some math (linear algebra in this case) saves a lot of code and CPU
+ I should repeat how to solve linear equations.
+ I couldn't reuse the *smart* solution from Part1. Back to Brute Force. Didn't like Part 2 event the resultig christmas tree was beautiful.

### Day 15

duration part 1: `3:20:00` roughly
duration part 2: ``
perceived difficulty Part 1: *easy* 
perceived difficulty Part 2: *complex* 

solution in:
[Solution Day 15 Part 1](abap/zclaoc2024_day15part1.abap)
[Solution Day 15 Part 2](abap/zclaoc2024_day15part2.abap)

##### Observations
+ it takes time in ABAP, maybe I'm not so fast....
+ this part remainded me of an old crate pushing game (I once implemented in haskell: https://github.com/fun-redoc/sokobal-revisited-no-frp.git)
+ again massive recursive algorithm....its getting complicated

### Day 16

duration part 1: `2:00:00` roughly
duration part 2: `1:30:00`
perceived difficulty Part 1: *middle* 
perceived difficulty Part 2: *middle* 

solution in:
[Solution Day 16 Part 1&2](java/de/rsh/aoc/aoc2024/AOC2024Day16.java)


##### Observations
+ used BFS again, the tricky part was that the maze had cycles, and the simple break criterion (i was here once) is not sufficient.
+ part 2 was not so hard if the solution of part 1 was able to produce all paths. mine was not, so i had to rewrite part 1.


### Day 17

duration part 1: `2:20:00` roughly
duration part 2: ``
perceived difficulty Part 1: *easy* 
perceived difficulty Part 2: *tricky* 

solution in:
[Solution Day 17 Part 1](abap/zclaoc2024_day17part1.abap)
[Solution Day 17 Part 2](python/main17part2.py)

##### Observations
+ it takes time in ABAP, maybe I'm not so fast....
+ one off errors...
+ I start to like the `reduce` operation in `ABAP`.
+ Part2 : took me some thinikng about and some experimentation in python, the main observation was, that the pattern repeats by mod 8 / div 8 and that one can reuse the results from rear to front. my first try the other way failed. A solution with a DP-tableau is really fine, havent done something alike since university... long time ago.


### Day 18

duration part 1: `4:30:00` roughly
duration part 2: ``
perceived difficulty Part 1: *middle* 
perceived difficulty Part 2: *easy* if you resolved Part 1 with an efficinet algorithm 

solution in:
[Solution Day 18 Part 1&2](abap/zclaoc2024_day18.abap)

##### Observations
+ the algorithm of choice is A*
+ the implementation in ABAP was not that hard I thought. the sorted table, hashed table etc. data types help a lot
+ i made some "bonckers" errors implementing the priority queue...
+ ABAP is missing generics.

### Day 19

duration part 1: `2:30:00` roughly
duration part 2: `1:30:00`
perceived difficulty Part 1: *ok* 
perceived difficulty Part 2: *struggeled* 

solution in:
[Solution Day 19 Part 1&2](abap/zclaoc2024_day19.abap)
[Solution Day (JAVA) 19 Part 1&2](java/de/rsh/aoc/aoc2024/AOC2024Day19.java)

##### Observations
+ the algorithm of choice is backtracking (BFS) supported by momoization 
+ roughly fir into th biggest number SAP proives
+ using fieldymbols and only chekcing for assignment can leed to time consuming errors
+ for fun i also implemented the solution in java 

### Day 20

duration part 1: `2:30:00` roughly
duration part 2: ``
perceived difficulty Part 1: *middle* 
perceived difficulty Part 2: *tricky* 

solution in:
[Solution Day 20 Part 1](java/de/rsh/aoc/aoc2024/AOC2024Day20.java)

##### Observations
+ the algorithm of choice is backtracking (BFS)### Day 23
+ this time used tabulation from dynamic progrmming
+ main Idea for Part 2 is moving a tabulated circle (square) around every element of the shortest path and checking if there is a cheat which meets the criteria within that circle.

### Day 21

duration part 1: `1:30:00` roughly
duration part 2: `endless`
perceived difficulty Part 1: *middle* 
perceived difficulty Part 2: *tricky* 

solution in:
[Solution Day 21 Part 1](java/de/rsh/aoc/aoc2024/AOC2024Day21.java)

##### Observations
+ a good caching strategy is needed, there are reains of my trials still in solution code
+ precomputing the shortest pathes within the key pad is the key idea
+ I came out with the solution first when i gave up trying to create the whole control code for level 25, stupid me, the quest only asks for the number, which is much easierer to compute

### Day 22

duration part 1: `0:30:00` 
duration part 2: `some 2:30:00` 
perceived difficulty Part 1: *easy* 
perceived difficulty Part 2: *maybe tricky very long text* 

solution in:
[Solution Day 22 Part 1&2](abap/zclaoc2024_day22.abap)

##### Observations
+ ABAP bit wise operation not on integers, conversion to the x type necessary
+ it was a good idea to find a representation for the delta sequences which can be stored and sought for easily (hashval)


### Day 23

duration part 1: `3:20:00` roughly
duration part 2: `0:22:00` but this was the 3 attempt, i lost mutch time trying to solve the problem without the CS tip from wikipedia concerning finding some maximal clique.
perceived difficulty Part 1: *ok* 
perceived difficulty Part 2: *tricky* 

solution in:
[Solution Day 23 Part 1&2](abap/zclaoc2024_day23.abap)

##### Observations
+ another variant of BFS 
+ hard to write a fast algorithm
+ findig maximal clique algorithm 
+ 2 failed attempts...i've been probably thinking to complicated, but one look in wikipedia should have been helping: https://en.wikipedia.org/wiki/Clique_problem

### Day 24

duration part 1: `2:50:00`
duration part 2: `2:00:00` took me some time to have an idea 
perceived difficulty Part 1: *ok* 
perceived difficulty Part 2: *tricky* 

solution in:
[Solution Day 24 Part 1&2](abap/zclaoc2024_day24.abap)

##### Observations
+ unexpectedly fast solution using pointers to connect the gates and memoising intermediate results
+ discovered new way of casting pointer in new ABAP without the indirection with `field-symbols` .. simply used `cast <ref_type>( <data> )`, i the same as for objects. same for `create data`, can be replaced by `new <ref_type>( )` - I like this
+ part 2 was for engeneers: wikipedida: https://en.wikipedia.org/wiki/Carry-lookahead_adder#Expansion
 

### Day 25

duration part 1: `1:30:00` roughly
duration part 2: `` 
perceived difficulty Part 1: *ok* 
perceived difficulty Part 2: **

solution in:
[Solution Day 25 Part 1&2](abap/zclaoc2024_day25.abap)

##### Observations
+ really nice one for the finish


## Copyrights and Credits
+ [SAP](https://www.sap.de/), miniSAP, SAP NW, SAP Netweaver, ADT, SE80, SAPGUI, bsp,  [ABAP](https://community.sap.com/topics/abap) etc. blong to SAP Company
+ [JAVA](https://www.java.com/en/download/help/whatis_java.html)
+ [SAP NW ABAP Trial in Docker by Brandon Caulfield](https://github.com/brandoncaulfield/sap-nw-abap-trial-docker-windows).
+ [eclipse](www.eclipse.org)
+ [picocss](https://picocss.com) minimalistic `css` framework
+ [Advent of Code](https://adventofcode.com/2024)