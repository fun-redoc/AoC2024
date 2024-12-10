# AoC2024
Advent of Code 2024 in ABAP and JAVA.

This years Advent of Code I'm going to resolve mostly in [ABAP](https://en.wikipedia.org/wiki/ABAP).

ABAP is probably not the most suitable language for this purpose, but non the less.

In case a puzzle beeing to tedious for ABAP I can switch java, e.g. if data structures like `Set` or `Map` will be needed and there is no simple way to replace them with ABAP tables. I'm very curious if this will happen.

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

I have not found the solution for part 2. 
Found 1161 but its to low. I'will have to produce own testcases and trying to undestand better the differen cases.

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

### Day 10

duration part 1 and 2: `2:00:00` perceived difficulty Part 1: *middle*
perceived difficulty Part 2: *easy*

solution in:
[Solution Day 10](abap/zclaoc2024_day10.abap)

# Bye Bye for today, see you hopefully tomorrow. Have a peaceful advent and stay coding...

##### Observations
+ another puzzle which could be solved using recursion (depth first) easily. nontheless respecting all the constraints is complex (for me).



## Copyrights and Credits
+ [SAP](https://www.sap.de/), miniSAP, SAP NW, SAP Netweaver, ADT, SE80, SAPGUI, bsp,  [ABAP](https://community.sap.com/topics/abap) etc. blong to SAP Company
+ [JAVA](https://www.java.com/en/download/help/whatis_java.html)
+ [SAP NW ABAP Trial in Docker by Brandon Caulfield](https://github.com/brandoncaulfield/sap-nw-abap-trial-docker-windows).
+ [eclipse](www.eclipse.org)
+ [picocss](https://picocss.com) minimalistic `css` framework
+ [Advent of Code](https://adventofcode.com/2024)