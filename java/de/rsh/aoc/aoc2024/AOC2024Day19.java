package de.rsh.aoc.aoc2024;

import de.rsh.aoc.AOC202XBase;
import de.rsh.aoc.aoc2023.AOC2023Day10;

import java.math.BigInteger;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AOC2024Day19 extends AOC202XBase {
    public static record Head(int headLen, int patCnt ){};
    public static record Adjacency(String pat, ArrayList<Integer> adj, ArrayList<String> adjPat){};
    static String[] designs;
    static String[] patterns;
    static Adjacency[] patternAdjacencyMatrix;
    static LinkedList<Head> queue = new LinkedList<>();
    public static void enq(Head cur) {
        queue.addLast(cur);
    }
    public static void push(Head cur) {
        queue.addFirst(cur);
    }
    public static Head pop() {
        if(queue.isEmpty()) return  null;
        return queue.remove();
    }
    public static Head deq() {
        if(queue.isEmpty()) return  null;
        return queue.remove();
    }
    static int dfs(String design) {
        int totalPatterns = 0;
        while(queue.removeIf(_->!queue.isEmpty()));
        push( new Head(0,0));
        for(Head cur = pop(); cur != null; cur = pop()) {
            for(var pat:patterns) {
                if(design.startsWith(pat,cur.headLen)) {
                    int newHeadLen = cur.headLen + pat.length();
                    if(newHeadLen == design.length()) {
                        totalPatterns++;
                    } else {
                        if( newHeadLen < design.length() ) {
                            push(new Head(newHeadLen, cur.patCnt+1));
                        }
                    }
                }
            }
        }
        return totalPatterns;
    }
    static int bfs(String design) {
        int totalPatterns = 0;
        while(queue.removeIf(_->!queue.isEmpty()));
        enq( new Head(0,0));
        for(Head cur = deq(); cur != null; cur = deq()) {
            for(var pat:patterns) {
                if(design.startsWith(pat,cur.headLen)) {
                    int newHeadLen = cur.headLen + pat.length();
                    if(newHeadLen == design.length()) {
                        totalPatterns++;
                    } else {
                        if( newHeadLen < design.length() ) {
                            enq(new Head(newHeadLen, cur.patCnt+1));
                        }
                    }
                }
            }
        }
        return totalPatterns;
    }
    public static record PatternNeighbour(int designIdx, int patIdx, String pat, String head, String tail, Queue<String> trace){};
    public static  int ways(String design) {
        int totalPatterns = 0;
        Stack<PatternNeighbour> stack = new Stack<>();
        // TODO search for the first viable startPat or this is a Pattern which comlettly maches the design search one that doesn't
        for(int i=0; i<patternAdjacencyMatrix.length; i++) {
            var startPat = patternAdjacencyMatrix[i].pat;
            if(startPat.length() > 0 && design.startsWith(startPat)) {
                var startAdjPatIdx = patternAdjacencyMatrix[i].adj.get(0);
                var startAdjPat = patternAdjacencyMatrix[startAdjPatIdx].pat;
                var startTrace = new LinkedList<String>();
                startTrace.add(startPat);
                stack.push(new PatternNeighbour(startPat.length(), i, startPat, design.substring(0, startPat.length()), design.substring(startPat.length()), startTrace));
            }
        }
        while(!stack.isEmpty()) {
           PatternNeighbour cur = stack.pop();
           if(cur.patIdx == patternAdjacencyMatrix.length-1 ||  cur.designIdx == design.length()) {
               if(cur.designIdx == design.length()) {
                   totalPatterns++;
               }
           } else {
               if(cur.patIdx < patternAdjacencyMatrix.length )
               {
                   var curDesign = design.substring(cur.designIdx);
                   var curPat = patternAdjacencyMatrix[cur.patIdx].pat;
                   var curAdj = patternAdjacencyMatrix[cur.patIdx].adj;
                   for(int i=0; i < curAdj.size(); i++) {
                       var nextAdjPatIdx = curAdj.get(i);
                       var nextAdjPat = patternAdjacencyMatrix[nextAdjPatIdx].pat; // ASSUMPTION Adjacences are korrectly set
                       if(curDesign.startsWith(nextAdjPat)) {
                           var nextDesignIdx = cur.designIdx +nextAdjPat.length();
                           var nextTrace = new LinkedList<String>(cur.trace);
                           nextTrace.add(nextAdjPat);
                           var curHead = design.substring(0, nextDesignIdx);
                           var curTail = design.substring(nextDesignIdx);
                           stack.push(new PatternNeighbour(nextDesignIdx, nextAdjPatIdx, nextAdjPat,  curHead, curTail, nextTrace));
                       }
                   }
               }
           }
        }
        return totalPatterns;
    }
    static record MemoKey(String design, int patIdx){
        @Override
        public boolean equals(Object obj) {
            MemoKey other = (MemoKey) obj;
            return design.equals(other.design) && patIdx == other.patIdx ;
        }

        @Override
        public int hashCode() {
            return (design + patIdx).hashCode() ;
        }
    };
    public static BigInteger ways_rec(String design, BigInteger acc, Map<String, BigInteger> memo) {
        if(design.length() == 0) {
            return acc.add(BigInteger.ONE);
        }
        var memoCnt = memo.get(design);
        if(memoCnt != null) {
            return memoCnt;
        }
        BigInteger cntTotal = new BigInteger(acc.toByteArray());
        for(int patIdx = 0; patIdx < patternAdjacencyMatrix.length; patIdx++) {
            var pat = patternAdjacencyMatrix[patIdx].pat;
            var adj = patternAdjacencyMatrix[patIdx].adj;
            BigInteger cnt1 = BigInteger.ZERO ;
            if(design.startsWith(pat)) {
                var tailDesign = design.substring(pat.length());
                memoCnt = memo.get(tailDesign);
                if(memoCnt != null) {
                    cnt1 = new BigInteger(memoCnt.toByteArray());
                } else {
                    if(tailDesign.length() > 0) {
                        for(int adjIdx = 0; adjIdx < adj.size(); adjIdx++) {
                            var adjPat = patternAdjacencyMatrix[adj.get(adjIdx)].pat;
                            if(tailDesign.startsWith(adjPat)) {
                                BigInteger cnt0 = BigInteger.ZERO;
                                memoCnt = memo.get(tailDesign);
                                if(memoCnt != null) {
                                    cnt0 = new BigInteger(memoCnt.toByteArray());
                                } else {
                                    var adjTailDesign = tailDesign.substring(adjPat.length());
                                    cnt0 = ways_rec(adjTailDesign,BigInteger.ZERO, memo);
                                    // memo
                                    memo.put(adjTailDesign, cnt0);
                                }
                                cnt1 = cnt1.add(cnt0);
                            }
                        }
                    } else {
                        cnt1 = cnt1.add(BigInteger.ONE);
                    }
                    //memo
                    memo.put(tailDesign, cnt1);
                }
            }
            cntTotal = cntTotal.add(cnt1);
        }
        //memo
        memo.put(design,cntTotal);
        return cntTotal;
    }
    public static void main(String[] argv) {
        var solution = solveWithFile(argv, br->
        {
            String line;
            int row = 0;
            ArrayList<String> tmpDesigns = new ArrayList<>();
            Set<String> tmpPatterns = new HashSet<>();
            String regex = "(\\w+)";
            Pattern pattern = Pattern.compile(regex);
            while((line = br.readLine()) != null) {
               if(row>0) {
                   // read designs
                   if( line.length() > 0) tmpDesigns.add(line);
               } else {
                   // read patterns
                   Matcher matcher = pattern.matcher(line);
                   while (matcher.find()) {
                       tmpPatterns.add(matcher.group());
                   }
               }
               row++;
            }
            designs = new String[tmpDesigns.size()];
            designs = tmpDesigns.toArray(designs);
            patterns = new String[tmpPatterns.size()];
            patterns = tmpPatterns.toArray(patterns);

            patternAdjacencyMatrix = new Adjacency[patterns.length];
            for(int i = 0; i <patterns.length; i++) {
                patternAdjacencyMatrix[i] = new Adjacency(patterns[i], new ArrayList<>(), new ArrayList<>() );
                for(int j = 0; j < patterns.length; j++) {
                    //if(i != j) { // loops!!!
                        patternAdjacencyMatrix[i].adj.add(j);
                        patternAdjacencyMatrix[i].adjPat.add(patterns[j]);
                    //}
                }
            }

            BigInteger totalCntPatterns = BigInteger.ZERO;
            int designCnt = 0;
            for(var design: tmpDesigns ) {
                //var cntPatternsInDesign = dfs( design );
                System.out.printf("Starting checking design %d %s", designCnt, design);
                //var cntPatternsInDesign = ways(design);
                var memo = new HashMap<String, BigInteger>();
                var cntPatternsInDesign = ways_rec(design, BigInteger.ZERO, memo);
                System.out.printf(" - %d patterns found\n",cntPatternsInDesign);
                totalCntPatterns = totalCntPatterns.add(cntPatternsInDesign);
                designCnt++;
            }
            return String.format("Total Patterns needed: %d", totalCntPatterns);
        });
        System.out.println(solution);
    }
}
