package de.rsh.aoc.aoc2024;

import de.rsh.aoc.AOC202XBase;
import de.rsh.aoc.Matrix;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static de.rsh.aoc.Matrix.dirs;

public class AOC2024Day16 extends AOC202XBase {
    record PathElem(Matrix.V2 p, Matrix.V2 facing, long score, PathElem pred){
        @Override
        public boolean equals(Object o) {
            if (!(o instanceof PathElem pathElem)) return false;
            if(!(pred != null) || pathElem.pred != null) {
                return Objects.equals(p(), pathElem.p()) && Objects.equals(pred.p, pathElem.pred.p);
            } else {
                return false;
            }
        }
        @Override
        public int hashCode() {
            return  Objects.hash(p, pred != null ? pred.p:null);
        }
    }

    //static Matrix<Character> map = null;
    static Set<Matrix.V2> walls = new HashSet<>();
    static Matrix.V2 start;
    static Matrix.V2 end;
    static Matrix.V2 dims;
    static Function<Matrix.V2,Boolean> inBounds = null;

    static void readPuzzle(BufferedReader br) throws IOException {
        String line = null;
        int row = 0;
        int col = 0;
        String regex = "([#.SE])";
        var pattern = Pattern.compile(regex);
        while((line = br.readLine()) != null) {
            Matcher matcher = pattern.matcher(line);
            while(matcher.find()) {
                var matcherResult = matcher.toMatchResult();
                col = matcherResult.start();
                var gridElem = matcherResult.group();
                switch (gridElem) {
                    case "S": start = new Matrix.V2(col, row);break;
                    case "E":   end = new Matrix.V2(col, row);break;
                    case "#": walls.add(new Matrix.V2(col, row)); break;
                    case ".":break;
                }
            }
            row++;
        }
        dims = new Matrix.V2(col, row);
        inBounds = (Matrix.V2 p)->0<= p.x() && p.x() < dims.x() && 0 <= p.y() && p.y() < dims.y() ;
    }

    static List<PathElem> dfs(Matrix.V2 start, Matrix.V2 end) {

        PathElem cur = null;
       Queue<PathElem> queue = new LinkedList<>();
       Map<PathElem,PathElem> visited = new HashMap<>();

       queue.add(new PathElem(start, Matrix.Dir.E.vec(), 0, null));
       long minScore = Long.MAX_VALUE;
       List<PathElem> optimal = new ArrayList<>();
       while((cur = queue.poll()) != null) {
           if( cur.p.equals(end) &&  cur.score < minScore ) {
               optimal.removeAll(optimal);
               optimal.add(cur);
               minScore = cur.score;
               continue;
           } else {
               if( cur.p.equals(end) &&  cur.score == minScore ) {
                   optimal.add(cur);
                   continue;
               }
           }
           visited.put(cur, cur);
           var facing = cur.facing;
           do {
               var next = new PathElem(cur.p.go(facing), facing, cur.score + (cur.facing != facing ? 1001: 1), cur);
               if(visited.containsKey(next)) {
                   var alreadyVisited = visited.get(next);
                   if(alreadyVisited.score >= next.score) {
                       visited.replace(next, next);
                       queue.add(next);
                   }
               } else {
                   if(inBounds.apply(next.p) && !walls.contains(next.p)) {
                       queue.add(next);
                   }
               }
               facing = facing.turnLeft();
           } while(!facing.equals(cur.facing));
       }
       return optimal;
    }

    static List<Matrix.V2> unwind(PathElem e) {
        ArrayList<Matrix.V2> res = new ArrayList<>();
        var cur = e;
        while(cur != null ) {
            res.add(cur.p);
            cur = cur.pred;
        }
        return res;
    }

    public static void main(String[] argv) {
        var solution = solveWithFile(argv, br->
        {
            readPuzzle(br);

            var paths = dfs(start, end);

//            tabula = shortestPath(original, start, end);

            var bestPaths = paths.stream().collect(()->new ArrayList<PathElem>(),
                    (acc, p)->{
                        if(acc.isEmpty()) {
                            acc.add(p);
                        } else {
                            if(acc.get(0).score > p.score) {
                                acc.removeAll(acc);
                                acc.add(p);
                            } else {
                                if(acc.get(0).score == p.score) {
                                    acc.add(p);
                                }
                            }
                        }
                    },
                    (acc1, acc2)->{
                        acc1.addAll(acc2);
                    });
            Set<Matrix.V2> tilesOnBestPaths =
                    bestPaths.stream().collect(() -> new HashSet<>(),
                            (acc, p)->{acc.addAll(unwind(p));},
                            (acc1,acc2)->{acc1.addAll(acc2);});

// 625 too low
            return String.format("min score: %d, cnt path %d, cnt seats: %d \n",bestPaths.get(0).score, bestPaths.size(), tilesOnBestPaths.size());
        });
        System.out.println(solution);
    }
}