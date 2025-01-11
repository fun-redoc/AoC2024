package de.rsh.aoc;

import java.util.Map;
import java.util.Optional;

public class Matrix<T> {
    public static Dir[] dirs = {Matrix.Dir.W, Matrix.Dir.E, Matrix.Dir.N, Matrix.Dir.S};
    public static Map<Character, Dir> keyToDir = Map.of('^', Matrix.Dir.N, '<', Dir.W, 'v', Dir.S, '>', Dir.E);
    public static enum Dir {
        N(new V2(0, -1), '^'), S(new V2(0, +1), 'v'), W(new V2(-1, 0), '<'), E(new V2(+1, 0), '>');
        V2 dir;
        char c;
        Dir(V2 dir, char c) {
            this.dir = dir;
            this.c = c;
        }
        public V2 vec() {
            return dir;
        }
        public char c() {
            return c;
        }
    }

    public static record V2(int x, int y){
       public V2 go(Dir d) {
           return  new V2(x+d.dir.x, y+d.dir.y);
       }
        public V2 go(V2 v) { return  new V2(x+v.x, y+v.y); }
        public V2 sub(V2 v) { return  new V2(x-v.x, y-v.y); }
        public V2 go(int dx, int dy) { return  new V2(x+dx, y+dy); }
        public V2 turnLeft() {
           return new V2(y,-x);
        }
        @Override
        public V2 clone() {
            return new V2(x,y);
        }
        @Override
        public boolean equals(Object o) {
            if (!(o instanceof V2 v2)) throw new ClassCastException();
            return x() == v2.x() && y() == v2.y();
        }
        @Override
        public int hashCode() {
            int result = String.format("%d%d",x,y).hashCode();
            return result;
        }
    };
    int rows;
    int cols;
    T[] field;
    public Matrix(int rows, int cols) {
        this.cols = cols;
        this.rows = rows;
        field = (T[])new Object[rows*cols];
    }
    public Matrix(int rows, int cols, T initial) {
       this.cols = cols;
       this.rows = rows;
       field = (T[])new Object[rows*cols];
       for(int i = 0; i < rows*cols; i++) {
           field[i] = initial;
       }
    }

    public Matrix<T> clone() {
        var replica = new Matrix<T>(rows, cols);
        replica.field = field.clone();
        return  replica;
    }

    public boolean check(int x, int y) {
        return 0 <= x && x < cols && 0 <= y && y < rows;
    }
    public  boolean check(V2 p) {
        return  check(p.x, p.y);
    }
    public int cols() {
        return cols;
    }
    public int rows() {
        return  rows;
    }
    public T get(int x, int y) {
        return field[x + y*cols];
    }
    public T get(V2 pos) {
        return field[pos.x + pos.y*cols];
    }
    public Matrix<T> put(T t, int x, int y) {
        field[x + y*cols] = t;
        return this;
    }
    public Matrix<T> put(T t, V2 pos) {
        field[pos.x + pos.y*cols] = t;
        return this;
    }
    public <T extends Comparable<?>> Optional<V2> posOf(T c) {
        // TODO iff not performant enugh, may be memoizing content in a Map could help accelerate
        for(int y = 0; y < rows; y++) {
            for(int x = 0; x <cols; x++) {
                if( c.equals(get(x,y)) ) {
                    return Optional.of( new V2(x,y) );
                }
            }
        }
        return Optional.empty();
    }
    @Override
    public String toString() {
        int maxCellLen = 0;
        for(int y = 0; y < rows; y++) {
            for(int x = 0; x <cols; x++) {
                maxCellLen = Math.max(get(x,y).toString().length(), maxCellLen);
            }
        }
        StringBuffer mat = new StringBuffer();
        char[] templateCell = new char[maxCellLen];
        for(int i=0; i<maxCellLen;i++) {templateCell[i]=' ';}
        for(int y = 0; y < rows; y++) {
            mat.append('|');
            for(int x = 0; x <cols; x++) {
                var cell = templateCell.clone();
                var cellContent = get(x,y).toString();
                var cellContentLen = cellContent.length();
                for(int i=0; i< cellContentLen; i++) {
                    var off = maxCellLen - cellContentLen;
                    cell[off+i] = cellContent.charAt(i);
                }
                mat.append(cell);
                mat.append('|');
            }
            mat.append('\n');
            for(int i=0; i < cols*(maxCellLen + 1) +1; i++) {
                mat.append('-');
            }
            mat.append('\n');
        }
        return  mat.toString();
    }
}