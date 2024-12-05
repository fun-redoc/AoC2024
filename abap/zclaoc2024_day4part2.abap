class zclaoc2024_day4 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods:
        constructor,
        zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        t_ch1 type c length 1,
        begin of t_dir,
            x type i,
            y type i,
        end of t_dir.

        data:
            dir_left type t_dir,
            dir_left_up type t_dir,
            dir_up type t_dir,
            dir_right_up type t_dir,
            dir_right type t_dir,
            dir_right_down type t_dir,
            dir_down type t_dir,
            dir_left_down type t_dir.

    methods:
           count_xmas importing matrix type ref to zclaoc2024_day4_matrix dir type t_dir returning value(cnt) type i,
           read_matrix importing puzzleinput type string returning value(matrix) type ref to zclaoc2024_day4_matrix,
           part1
             importing
               value(matrix)  type ref to zclaoc2024_day4_matrix
             returning
                 VALUE(r_result_part1) TYPE i,
           x_mas1 importing value(matrix) type ref to zclaoc2024_day4_matrix
                            value(x) type i
                            value(y) type i
                            returning value(is_x_mas) type abap_bool,
           x_mas2 importing value(matrix) type ref to zclaoc2024_day4_matrix
                            value(x) type i
                            value(y) type i
                            returning value(is_x_mas) type abap_bool,
           x_mas3 importing value(matrix) type ref to zclaoc2024_day4_matrix
                            value(x) type i
                            value(y) type i
                            returning value(is_x_mas) type abap_bool,
           x_mas4 importing value(matrix) type ref to zclaoc2024_day4_matrix
                            value(x) type i
                            value(y) type i
                            returning value(is_x_mas) type abap_bool,
           x_masx importing value(matrix) type ref to zclaoc2024_day4_matrix
                            value(col) type i
                            value(row) type i
                            value(ne) type t_ch1 " north east
                            value(nw) type t_ch1 " norrthwest
                            value(se) type t_ch1 " southseast
                            value(sw) type t_ch1 " southseast
                            returning value(is_x_mas) type abap_bool,
           part2
             importing
               value(matrix)  type ref to zclaoc2024_day4_matrix
             returning
                 VALUE(r_result_part2) TYPE i. "copy paste is bonkers.
endclass.



class zclaoc2024_day4 implementation.
    method constructor.
       super->constructor( ).
       dir_left = value t_dir( x = -1 y = 0 ).
       dir_left_up = value t_dir( x = -1 y = -1 ).
       dir_up = value t_dir( x = 0 y = -1 ).
       dir_right_up = value t_dir( x = 1 y = -1 ).
       dir_right = value t_dir( x = 1 y = 0 ).
       dir_right_down = value t_dir( x = 1 y = 1 ).
       dir_down = value t_dir( x = 0 y = 1 ).
       dir_left_down = value t_dir( x = -1 y = 1 ).
    endmethod.
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
    method part1.

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
      data result_part1 type i value 0.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_right ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_right_up ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_up ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_left_up ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_left ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_left_down ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_down ) + r_result_part1.
      r_result_part1 = count_xmas( matrix = matrix dir = dir_right_down ) + r_result_part1.

    endmethod.

    method x_masx.
      " nw.ne
      "   A
      " sw.se
        is_x_mas = abap_false.
        check col gt 0 and col le matrix->cols and row gt 0 and row le matrix->rows.

        data(ch) = matrix->get( x = col y = row ).
        check ch eq 'A'.

        " nw
        data(x) = col + dir_left_up-x.
        data(y) = row + dir_left_up-y.
        check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
        ch = matrix->get( x = x y = y ).
        check ch eq nw.

        x = col + dir_right_up-x.
        y = row + dir_right_up-y.
        check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
        ch = matrix->get( x = x y = y ).
        check ch eq ne.

        x = col + dir_right_down-x.
        y = row + dir_right_down-y.
        check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
        ch = matrix->get( x = x y = y ).
        check ch eq se.

        x = col + dir_left_down-x.
        y = row + dir_left_down-y.
        check x gt 0 and x le matrix->cols and y gt 0 and y le matrix->rows.
        ch = matrix->get( x = x y = y ).
        check ch eq sw.

        is_x_mas = abap_true.
    endmethod.
    method x_mas1.
      " M.M
      "  A
      " S.S
      is_x_mas = x_masx(  matrix = matrix col = x row = y nw = 'M' ne = 'M' sw = 'S' se = 'S'  ).
    endmethod.
    method x_mas2.
      " S.S
      "  A
      " M.M
      is_x_mas = x_masx(  matrix = matrix col = x row = y nw = 'S' ne = 'S' sw = 'M' se = 'M'  ).
    endmethod.
    method x_mas3.
      " M.S
      "  A
      " M.S
      is_x_mas = x_masx(  matrix = matrix col = x row = y nw = 'M' ne = 'S' sw = 'M' se = 'S'  ).
    endmethod.
    method x_mas4.
      " M.M   S.S  M.S S.M
      "  A     A    A   A
      " S.S   M.M  M.S S.M
      is_x_mas = x_masx(  matrix = matrix col = x row = y nw = 'S' ne = 'M' sw = 'S' se = 'M'  ).
    endmethod.

    method part2.
      " find two MAS in the shape of an X
      " basic idea
      "  check every entry in the matrix if it is the
      "  midpoint of a MAS Xross.
      " Within the X, each MAS can be written forwards or backwards.
      " M.M   S.S  M.S S.M
      "  A     A    A   A
      " S.S   M.M  M.S S.M
      clear r_result_part2.
      do matrix->rows times.
        data(row) = sy-index.
        do matrix->cols times.
            data(col) = sy-index.
            data(ch) = matrix->get( x = col y = row ).
            check ch eq 'A'.

            check    x_mas1( matrix = matrix x = col y = row ) eq abap_true
                  or x_mas2( matrix = matrix x = col y = row ) eq abap_true
                  or x_mas3( matrix = matrix x = col y = row ) eq abap_true
                  or x_mas4( matrix = matrix x = col y = row ) eq abap_true.

                  " will it run??

            add 1 to r_result_part2.

        enddo.
      enddo.
    endmethod.

    method zif_aoc2024~resolve.

        data(matrix) = read_matrix( puzzleinput ).
        data(result_part1) = part1( matrix ).
        data(result_part2) = part2( matrix ).

       result = | Part 1: { result_part1 }; Part 2: { result_part2 }| .
    endmethod.

endclass.