package de.rsh.aoc.aoc2024;

import de.rsh.aoc.AOC202XBase;
import de.rsh.aoc.Matrix;

import java.awt.desktop.SystemSleepEvent;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AOC2024Day20  extends AOC202XBase {
    record PathElem(int steps, Matrix.V2 pred){
        @Override
        public String toString() {
            return String.valueOf(steps);
        }
    };
    record CheatStep(int steps, Matrix.V2 off, Matrix.V2 dir, Matrix.V2 pred){}
    static Matrix.Dir[] dirs = {Matrix.Dir.N, Matrix.Dir.S, Matrix.Dir.W, Matrix.Dir.E};
    static Matrix.V2 start = null;
    static Matrix.V2 end = null;
    static ArrayList<Matrix.V2> walls;
    static Matrix<Character> original;
    static Matrix<PathElem> tabula;
    static Matrix<CheatStep> tab40x40;
    static int saveQuorum = 100;

    public static Matrix.V2[] readPuzzle(BufferedReader br) throws IOException {
        Matrix.V2 drill1 = null;
        Matrix.V2 drill2 = null;

        String line;
        int row = 0;
        int col = 0;
        walls = new ArrayList<>();
        String regex = "([12SE#\\.])";
        Pattern pattern = Pattern.compile(regex);
        while((line = br.readLine()) != null) {
            Matcher matcher = pattern.matcher(line);
            while (matcher.find()) {
                MatchResult r = matcher.toMatchResult();
                col = r.start();
                switch (r.group()) {
                    case "S": start = new Matrix.V2(col, row);break;
                    case "E": end = new Matrix.V2(col, row); break;
                    case "#": walls.add(new Matrix.V2(col,row)); break;
                    case "1": walls.add(new Matrix.V2(col,row));
                              drill1 = new Matrix.V2(col, row);
                              break;
                    case "2": drill2 = new Matrix.V2(col, row); break;
                    case ".":break;
                }
            }
            row++;
        }
        int rows = row;
        int cols = col +1;
        original = new Matrix<Character>(rows,cols, '.');
        for(var wall:walls) {
            original.put('#', wall);
        }

        if(end == null && drill2 != null) {
            end = drill2;
        }
        if(start == null && drill1 != null) {
            start = drill1;
        }
        if(drill1 == null || drill2 == null){
            return null;
        } else {
            return new Matrix.V2[]{drill1, drill2};
        }
    }
    static record PathNode(Matrix.V2 p, PathNode pred){

        @Override
        public boolean equals(Object o) {
            if (!(o instanceof PathNode pathNode)) return false;

            return p().equals(pathNode.p());
        }

        @Override
        public int hashCode() {
            return p().hashCode();
        }
    };
    public static Matrix<PathElem> shortestPath(Matrix<Character> maze, Matrix.V2 start, Matrix.V2 end) {
        var tab = new Matrix<PathElem>(maze.rows(), maze.cols(), new PathElem(0,null));
        boolean ready = false;
        Queue<PathNode> queue = new LinkedList<>();
        Set<PathNode> closed = new HashSet<>();
        queue.add(new PathNode(start, null));
        int minSteps = Integer.MAX_VALUE;
        while(!queue.isEmpty()) {
            var cur = queue.poll();
            if(cur.p.equals(end)) {
                minSteps = tab.get(cur.p).steps;
                return tab;
            }
            closed.add(cur);
            for(var dir:dirs) {
                var steps = tab.get(cur.p).steps;
                var newPos = cur.p.go(dir);
                var newNd = new PathNode(newPos, cur);
                if(!closed.contains(newNd)) {
                    if(maze.check(newPos) && maze.get(newPos).charValue() != '#') {
                        var oldDirSteps = tab.get(newPos).steps;
                        var newDirSteps = oldDirSteps != 0 ? Math.min(oldDirSteps, steps + 1) : steps +1;
                        if(newDirSteps < minSteps) {
                            tab.put(new PathElem(newDirSteps, cur.p), newPos);
                            queue.add(newNd);
                        }
                    }
                } else {
                    if(!newPos.equals(cur.p.go(dir))) {
                        System.out.println("cycle found");
                    }
                }
            }
        }
        throw new RuntimeException("Segmentation Fault");
    }
    public static Matrix<Character> mazeWithDrill(Matrix<Character> original, Matrix.V2 drill1, Matrix.V2 drill2 ) {
        var replicaMaze = original.clone();
        replicaMaze.put('1', drill1);
        replicaMaze.put('2', drill2);
        return replicaMaze;
    }
    public static int blockTheWayBackToStart(Matrix<PathElem> tabula, Matrix<Character> maze, Matrix.V2 drill1, Matrix.V2 drill2) {
        Matrix.V2 minPos = null;
        Matrix.V2 peekPos = null;
        int minSteps = Integer.MAX_VALUE;
        for(var d:dirs) {
            peekPos = drill1.go(d);
            if(!peekPos.equals(drill2)) {
                if(maze.get(peekPos).charValue() != '#') {
                    var peekSteps = tabula.get(peekPos).steps;
                    if(minSteps > peekSteps) {
                        minSteps = peekSteps;
                        minPos = peekPos;
                    }
                }
            }
        }
        if(minPos != null) {
            maze.put('#', minPos);
        } else {
            throw new RuntimeException("cannot block, something worng with the drill");
        }
        return minSteps;
    }
    public static Matrix.V2 getPredecessor(Matrix.V2 drill1, Matrix.V2 drill2) {
        Matrix.V2 minPos = null;
        Matrix.V2 peekPos = null;
        int minSteps = Integer.MAX_VALUE;
        for(var d:dirs) {
            peekPos = drill1.go(d);
            if(original.check(peekPos) && !peekPos.equals(drill2)) {
                if(original.get(peekPos).charValue() != '#') {
                    var peekSteps = tabula.get(peekPos).steps;
                    if(minSteps > peekSteps) {
                        minSteps = peekSteps;
                        minPos = peekPos;
                    }
                }
            }
        }
        return minPos;
    }
    public static int cheat(Matrix.V2 drill1, Matrix.V2 drill2) {
        int stepsToCheat = 0;
        var mazeWithHole = mazeWithDrill(original, drill1, drill2);
        stepsToCheat = blockTheWayBackToStart(tabula, mazeWithHole, drill1, drill2);
        var tabulaWithCheat = shortestPath(mazeWithHole, drill1, end);

        System.out.println(mazeWithHole);
        System.out.println(tabulaWithCheat);

        var originalSteps =  tabula.get(end).steps;
        var cheatSteps = tabulaWithCheat.get(end).steps;
        return originalSteps - (stepsToCheat + 1 + cheatSteps);
    }
    public static int cheatNoSim(Matrix.V2 drill1, Matrix.V2 drill2) {
        var total = tabula.get(end).steps;
        var drill1Pred = getPredecessor(drill1, drill2);
        if(drill1Pred != null) {
            var stepsUntilCheat = tabula.get(drill1Pred).steps;
            var stepsUntilDrill2 = tabula.get(drill2).steps;
            var saved2 = stepsUntilDrill2 - stepsUntilCheat - 2;
            return saved2;
        }
        return  0;
    }
    public static int countWithTreshold(int t) {
        int cnt = 0;
         for(var w:walls) {
             for(var d:dirs) {
                 var ch1 = w;
                 var ch2 = w.go(d);
                 if(original.check(ch2) && original.get(ch2).charValue() != '#') {
                     var saved3 = cheatNoSim(ch1,ch2);
                     if(saved3 >= t) {
                        cnt++;
                     }
                 }
             }
         }
         return cnt;
    }
    static String part1() {
        int treshold = 100;
        int count = countWithTreshold(treshold);
        return String.format("%d cheats over %d", count, treshold);
    }
    static String part2() {
        var pos = end;
        //do {
        //
        //} while(pos != start);
        return "";
    }
    static Matrix<CheatStep>  generateDistTab(int dist) {
        var tab = new Matrix<CheatStep>(dist, dist, new CheatStep(Integer.MAX_VALUE,null, new Matrix.V2(0,0), null));
        var mid = new Matrix.V2(dist/2,dist/2);
        var pos = mid;
        tab.put(new CheatStep(0, pos.sub(mid), new Matrix.V2(0,0), null), pos);
        Queue<PathNode> queue = new LinkedList<PathNode>();
        Set<PathNode> finished = new HashSet<>();
        queue.add(new PathNode(pos, null));
        PathNode cur = null;
        while((cur = queue.poll()) != null) {
            finished.add(cur);
            for(var d:dirs) {
                var nextPos = cur.p.go(d);
                if(tab.check(nextPos)) {
                    var nextNode = new PathNode(nextPos, cur);
                    if(!finished.contains(nextNode)) {
                        var curElem = tab.get(cur.p);
                        var nextElem = tab.get(nextPos);
                        var oldDirSteps = tab.get(nextPos).steps;
                        var newDirSteps = oldDirSteps != 0 ? Math.min(oldDirSteps, curElem.steps + 1) : curElem.steps +1;
                        if(newDirSteps < oldDirSteps) {
                            tab.put(new CheatStep(newDirSteps, nextPos.sub(mid), nextPos.sub(cur.p), cur.p), nextPos);
                            queue.add(nextNode);
                        }
                    }
                }
            }
        }
        return tab;
    }
    static record Cheat(int savedSteps, List<Matrix.V2> sequence){}
    static List<Cheat> scanCheats(Matrix.V2 pos) {
        var cheats = new ArrayList<Cheat>();
        var distToEnd = tabula.get(end).steps;
        var distToPos = tabula.get(pos).steps;
        for(int y = 0 ; y < tab40x40.rows(); y++) {
            for(int x = 0; x < tab40x40.cols(); x++) {
                var cheatStep = tab40x40.get(x,y);
                var cheatSteps = cheatStep.steps;
                if(cheatSteps > 20 || cheatSteps < 1) continue; // the cheat shouldn't be longer than 20, 21 because we are one step before cheat entry
                var cheatOff = cheatStep.off;
                var potentialCheatStart = pos.go(cheatOff);
                if(original.check(potentialCheatStart) && original.get(potentialCheatStart) == '.' ) { // before entering cheat one has to be on the legal path)
                    var cheatStepPred = tab40x40.get(cheatStep.pred);
                    var cheatStepPredOff = cheatStepPred.off;
                    var potentialCheatEntry = pos.go(cheatStepPredOff);
                    if(!original.check(potentialCheatEntry)) continue;
                    var stepsWithCheat = tabula.get(potentialCheatStart).steps + cheatSteps + (distToEnd - distToPos);
                    var potentiallySavedSteps = distToEnd - stepsWithCheat;
                    var stepObject = original.get(potentialCheatEntry);
                    //if( stepObject == '#' )
                    { // cheat start should be in a wall
                        if(    cheatSteps <= 20 ) {  // the cheat shouldn't be longer than 20, 21 because we are one step before cheat entry
                            if( potentiallySavedSteps >= saveQuorum // at least saved
                            ) {
                                var sequence = new ArrayList<Matrix.V2>();
                                var cur = cheatStep; // this is a step before entry to cheat
                                do {
                                    var curPos = cur.pred;
                                    var off = tab40x40.get(curPos).off;
                                    var seqPos = pos.go(off);
                                    sequence.add(seqPos);
                                    cur = tab40x40.get(curPos);
                                } while(cur.pred != null);
                                var cheat = new Cheat(potentiallySavedSteps, sequence);
                                cheats.add(cheat);
                            }
                        }
                    }
                }
            }
        }
        return cheats;
    }
    public static void main(String[] argv) {
        var solution = solveWithFile(argv, br->
        {
            var drills = readPuzzle(br);
            tabula = shortestPath(original, start, end);
            tab40x40 = generateDistTab(42); // in reality 42 * 42
            //System.out.println(tabula);
            //System.out.println(tab40x40);
            var solutionPart1 = part1();

            // Part 2
            saveQuorum = Integer.valueOf(argv[0]);
            // go back from end to start
            var cur = end;
            var savedAll = new ArrayList<Cheat>();
            while (!cur.equals(start)) {
                var saved =  scanCheats(cur);
                savedAll.addAll(saved);
                cur = tabula.get(cur).pred;
            }

            var resultMap = new HashMap<Integer, Integer>();
            for(var s: savedAll) {
                if(resultMap.containsKey(s.savedSteps)) {
                    var cnt = resultMap.get(s.savedSteps);
                    resultMap.replace(s.savedSteps, cnt + 1 );
                } else {
                    resultMap.put(s.savedSteps, 1);
                }
            }

            int result_part2 = 0;
            for(var r:resultMap.keySet().stream().sorted().toList()) {
                var cnt = resultMap.get(r);
                System.out.printf("%d save %d\n", cnt, r);
                result_part2 += cnt;
            }

            return String.format("\nPart 1: %s, Part 2: %d \n", solutionPart1, result_part2);
        });
        System.out.println(solution);
    }
}