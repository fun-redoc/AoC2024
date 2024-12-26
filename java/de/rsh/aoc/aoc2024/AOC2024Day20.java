package de.rsh.aoc.aoc2024;

import de.rsh.aoc.AOC202XBase;
import de.rsh.aoc.Matrix;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AOC2024Day20  extends AOC202XBase {
    static record PathElem(int steps, Matrix.V2 pred){
        @Override
        public String toString() {
            return String.valueOf(steps);
        }
    };
    static Matrix.Dir[] dirs = {Matrix.Dir.N, Matrix.Dir.S, Matrix.Dir.W, Matrix.Dir.E};
    static Matrix.V2 start = null;
    static Matrix.V2 end = null;
    static ArrayList<Matrix.V2> walls;
    static Matrix<Character> original;
    static Matrix<PathElem> tabula;
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
    public static void main(String[] argv) {
        var solution = solveWithFile(argv, br->
        {
            var drills = readPuzzle(br);
            tabula = shortestPath(original, start, end);

            int treshold = 100;
            int count = countWithTreshold(treshold);
            return String.format("%d cheats over %d", count, treshold);

        });
        System.out.println(solution);
    }
}