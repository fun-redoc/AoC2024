package de.rsh.aoc.aoc2024;

import de.rsh.aoc.AOC202XBase;
import de.rsh.aoc.Matrix;

import java.math.BigInteger;
import java.util.*;


class Pad {
    public static class PreCalc {
        Map<Pair<Character, Character>, Pair<Integer, List<String>>> shortesPathsPreCalc = new HashMap<>();
        PreCalc(Pad pad) {
            var cntMoves = pad.layout.length * pad.layout[0].length - 1; // minus # - Field
            char[] moves = new char[cntMoves];
            int m = 0;
            for(int i = 0; i <pad.layout.length; i++) {
                for(int j = 0; j < pad.layout[i].length; j++) {
                    if(pad.layout[i][j] != '#') moves[m++] = pad.layout[i][j];
                }
            }
            for (char start : moves) {
                for (char dest : moves) {
                    var shortestPathes = pad.shortestPathsBetweenKeysDFS(start, dest);

                    // key sequence allways should end with A
                    if (shortestPathes.isEmpty()) {
                        shortestPathes.add("A");
                    } else {
                        shortestPathes = shortestPathes.stream().map(aPath -> aPath + "A").toList();
                    }
                    shortesPathsPreCalc.put(new Pair<>(start, dest), new Pair<>(shortestPathes.getFirst().length(), shortestPathes));
                }
            }
        }
        public Pair<Integer, List<String>> get(char start, char dest) {
            return shortesPathsPreCalc.get(new Pair<>(start, dest));
        }
    }
    record PadQueueEntry(Matrix.V2 pos, Matrix.Dir d, int steps, PadQueueEntry prev) {
        @Override
        public boolean equals(Object o) {
            if (!(o instanceof PadQueueEntry that)) return false;
            return pos().equals(that.pos());
        }
        @Override
        public int hashCode() {
            return pos().hashCode();
        }
    }
    Matrix<Character> padMatrix;
    Matrix.V2 A;
    Map<Pair<Character,Character>,List<String>> memoPath = new HashMap<>();
    PreCalc preCalc;
    char[][] layout;
    public Pad(char[][] layout) {
        var rows = layout.length;
        var cols = layout[0].length; // its OK to throw runtime exception when the layout has no rows
        padMatrix = new Matrix<>(rows, cols);
        this.layout = layout;
        for(int r=0; r < rows; r++) {
            for(int c=0; c < cols; c++) {
                var key = layout[r][c];
                padMatrix.put(key, c, r);
                if(key == 'A') {
                    this.A = new Matrix.V2(c,r);
                }
            }
        }
        this.preCalc = new PreCalc(this);
    }
    List<String> shortestPathsBetweenKeysDFS(char startKey, char destKey) {
        // this should be memoized
        List<String> shortestPathes;
        if((shortestPathes = memoPath.get(new Pair<>(startKey, destKey))) != null ) {
            return  shortestPathes;
        }
        // I#m going to use dfs
        shortestPathes = new ArrayList<>();
        Queue<PadQueueEntry> queue = new LinkedList<>();
        Set<PadQueueEntry> finished = new HashSet<>();
        int minSteps = Integer.MAX_VALUE;

        var destPos = padMatrix.posOf(destKey).get(); // no isPresent test is ok here
        var startPos = padMatrix.posOf(startKey).get();

        queue.add(new PadQueueEntry(startPos, null, 0, null)); // for this cas OK throwing null pointer exception
        PadQueueEntry cur;
        while((cur = queue.poll()) != null) {
            if(cur.pos.equals(destPos) && cur.steps <= minSteps ) {
                PadQueueEntry aux = cur;
                StringBuilder sb = new StringBuilder();
                if(cur.steps < minSteps) {
                    minSteps = cur.steps;
                    shortestPathes.removeAll(shortestPathes);
                }
                while(aux.prev != null) {
                    sb.append(aux.d.c());
                    aux = aux.prev;
                }
                shortestPathes.add(sb.reverse().toString());
            }
            finished.add(cur);
            for(var d: Matrix.dirs) {
                var newEntry = new PadQueueEntry(cur.pos.go(d), d, cur.steps + 1, cur);
                if(padMatrix.check(newEntry.pos) && padMatrix.get(newEntry.pos) != '#') {
                    if( newEntry.steps <= minSteps ) {
                        if(!finished.contains(newEntry)) {
                            queue.add(newEntry); // new candidate to take in
                        }
                    }
                }
            }
        }
        // memoize
        memoPath.put(new Pair<>(startKey, destKey), shortestPathes);
        return shortestPathes;
    }
    public Pair<Integer, List<String>> shortestPathsBetweenKeys(char start, char dest) {
        return preCalc.get(start, dest);
    }
}


public class AOC2024Day21 extends AOC202XBase {
    public enum Pads {
        NUM_PAD(new Pad(new char[][]{{'7','8','9'}, {'4','5','6'}, {'1','2','3'}, {'#','0', 'A'}})),
        ARR_PAD(new Pad(new char[][]{{'#','^','A'},{'<','v','>'}}));
        final Pad pad;
        Pads(Pad pad) {
            this.pad = pad;
        }
        Pad get() {
            return this.pad;
        }
    }
    record MemoEntry<T,S,R>(T t, S s, R r) {}
    Map<MemoEntry<Character,Character,Integer>,BigInteger> memo = new HashMap<>();
    BigInteger determinMinPathLen(Pad pad, char start, char dest, int chainLen){
       var memoEntry = new MemoEntry<>(start, dest, chainLen);
       if(memo.containsKey(memoEntry)) {
           return memo.get(memoEntry);
       }
       if(chainLen == 0) {
           return BigInteger.valueOf(pad.shortestPathsBetweenKeys(start, dest).t());
       }

       var pathes = pad.shortestPathsBetweenKeys(start, dest).s();
       BigInteger minLen = BigInteger.ONE.shiftLeft(128); // start with a very big value hopefully vig enough
       for(var path:pathes) {
           var pathWithA = "A"+path;
           BigInteger pathLen = BigInteger.ZERO;
           for(int i=0; i<pathWithA.length()-1;i++) {
               pathLen = pathLen.add(determinMinPathLen(Pads.ARR_PAD.get(),pathWithA.charAt(i), pathWithA.charAt(i+1), chainLen-1));
           }
           minLen = minLen.min(pathLen);
       }
       memo.put(memoEntry, minLen);
       return minLen;
    }
    public BigInteger determinMinKeyPresses(String code, int chainLen) {
       var codeWithStartAtA = "A"+code;
       var minKeyPresses = BigInteger.ZERO;
       for(int i = 0; i<codeWithStartAtA.length()-1; i++) {
           minKeyPresses = minKeyPresses.add(determinMinPathLen(Pads.NUM_PAD.get(),codeWithStartAtA.charAt(i), codeWithStartAtA.charAt(i+1), chainLen));
       }
       return minKeyPresses;
    }
    public static void main(String[] argv) {
        var solution  = solveWithFile(argv, br -> {
            /*
            * this is a long text to grok, but letz go step by step
            * 1. first i need movements within a keypad and shortest pathes from
            * one key to the other
            * 2. second, the pathes have to be concatenated (here there my be a combinatorical explosion!)
            * 3. find the min path solution
            * 4. looking for optimization not having to compute or combination
            *    of pathes through the keypad especially in the
            *    thrd case of robot indirection
             */
            var solver =  new AOC2024Day21();
            String line;
            var chainLen = 25;
            BigInteger res = BigInteger.ZERO;
            while((line = br.readLine()) != null) {
                var min_key_presses = solver.determinMinKeyPresses(line, chainLen);
                System.out.printf("%s: %d\n", line, min_key_presses);
                res = res.add(min_key_presses.multiply(BigInteger.valueOf(Long.parseLong(line.substring(0, line.length()-1)))));
            }
            return String.format("Part 2: %d", res);
        });
        System.out.println(solution);
    }
}