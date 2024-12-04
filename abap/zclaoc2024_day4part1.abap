class zclaoc2024_day4 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_dir,
            x type i,
            y type i,
        end of t_dir.

    methods:
           count_xmas importing matrix type ref to zclaoc2024_day4_matrix dir type t_dir returning value(cnt) type i,
           read_matrix importing puzzleinput type string returning value(matrix) type ref to zclaoc2024_day4_matrix.
endclass.



class zclaoc2024_day4 implementation.
    method count_xmas.
        do matrix->rows times.
            data(row) = sy-index.
            do matrix->cols times.
                data(col) = sy-index.
                data(ch) = matrix->get( x = col y = row ).
                check ch eq 'X'.

                data(x) = col + dir-x.
                data(y) = row + dir-y.
                check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
                ch = matrix->get( x = x y = y ).
                check ch eq 'M'.

                x = x + dir-x.
                y = y + dir-y.
                check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
                ch = matrix->get( x = x y = y ).
                check ch eq 'A'.

                x = x + dir-x.
                y = y + dir-y.
                check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
                ch = matrix->get( x = x y = y ).
                check ch eq 'S'.

                add 1 to cnt.
            enddo.
       enddo.
    endmethod.
    method read_matrix.
        data(lines) = split_into_lines( puzzleinput ).
        data(rows) = lines(  lines ).
        " in ABAP tables (arrays) are 1-based....
        data(cols) = strlen(  lines[ 1 ] ). " assumption all lines have the same length...
        matrix = new #( rows = rows cols = cols ).
        loop at lines assigning field-symbol(<line>).
            matrix->put_row_from_string( content = <line> row = sy-tabix ).
        endloop.
    endmethod.
    method zif_aoc2024~resolve.
       "word allows to be horizontal, vertical, diagonal, written backwards,
       "or even overlapping other words
       " IDEA:
       " 0. read words int a matrix (2-dim)
       " 1. for each cells of the matrix
       " 2.1. gather 4 cells to the left -> check if equals xmas
       " 2.2. gather 4 cells to the up left -> check if equals xmas
       " 2.3. gather 4 cells to the up -> check if equals xmas
       " 2.4. gather 4 cells to the up right -> check if equals xmas
       " 2.5. gather 4 cells to the right -> check if equals xmas
       " 2.6. gather 4 cells to the down right -> check if equals xmas
       " 2.7. gather 4 cells to the down -> check if equals xmas
       " 2.8. gather 4 cells to the down left -> check if equals xmas
       data(dir_left) = value t_dir( x = -1 y = 0 ).
       data(dir_left_up) = value t_dir( x = -1 y = -1 ).
       data(dir_up) = value t_dir( x = 0 y = -1 ).
       data(dir_right_up) = value t_dir( x = 1 y = -1 ).
       data(dir_right) = value t_dir( x = 1 y = 0 ).
       data(dir_right_down) = value t_dir( x = 1 y = 1 ).
       data(dir_down) = value t_dir( x = 0 y = 1 ).
       data(dir_left_down) = value t_dir( x = -1 y = 1 ).
       " all 2 combinations of (-1,0,1)

       data result_part1 type i value 0.
       data(matrix) = read_matrix( puzzleinput ).
       result_part1 = count_xmas( matrix = matrix dir = dir_right ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_right_up ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_up ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_left_up ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_left ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_left_down ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_down ) + result_part1.
       result_part1 = count_xmas( matrix = matrix dir = dir_right_down ) + result_part1.
       

       result = | Part 1: { result_part1 }| .
    endmethod.
endclass.