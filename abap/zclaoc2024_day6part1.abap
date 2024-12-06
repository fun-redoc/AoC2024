class zclaoc2024_day6 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition,
             constructor.
  protected section.
  private section.
      types:
        tt_trace type table of zclaoc2024_day4_matrix=>t_v2.
*        begin of zclaoc2024_day4_matrix=>t_v2,
*            x type i,
*            y type i,
*        end of zclaoc2024_day4_matrix=>t_v2.
        data:
            go_w type zclaoc2024_day4_matrix=>t_v2,
            go_nw type zclaoc2024_day4_matrix=>t_v2,
            go_n type zclaoc2024_day4_matrix=>t_v2,
            go_ne type zclaoc2024_day4_matrix=>t_v2,
            go_e type zclaoc2024_day4_matrix=>t_v2,
            go_se type zclaoc2024_day4_matrix=>t_v2,
            go_s type zclaoc2024_day4_matrix=>t_v2,
            go_sw type zclaoc2024_day4_matrix=>t_v2,

            map type ref to zclaoc2024_day4_matrix.

       methods:
            goes_out_of_map importing pos type zclaoc2024_day4_matrix=>t_v2
                                      dir type zclaoc2024_day4_matrix=>t_v2
                            returning value(res) type abap_bool,
            can_go_ahead importing pos type zclaoc2024_day4_matrix=>t_v2
                                   dir type zclaoc2024_day4_matrix=>t_v2
                         returning value(res) type abap_bool,
            go_ahead importing pos type zclaoc2024_day4_matrix=>t_v2
                               dir type zclaoc2024_day4_matrix=>t_v2
                     returning value(new_pos) type zclaoc2024_day4_matrix=>t_v2 ,
            turn_right importing dir type zclaoc2024_day4_matrix=>t_v2
                       returning value(new_dir) type zclaoc2024_day4_matrix=>t_v2 ,
            walk_around importing map type ref to zclaoc2024_day4_matrix
                                  guard_pos type zclaoc2024_day4_matrix=>t_v2
                        changing trace type tt_trace.

endclass.



class zclaoc2024_day6 implementation.
  method goes_out_of_map.
    data(new_pos) = go_ahead( pos = pos dir = dir ).
    if map->check_in_bounds( new_pos ).
        res = abap_false. " does not go out
    else.
        res = abap_true. " goes out
    endif.
  endmethod.
  method can_go_ahead."( pos  dir).
    res = abap_false.
    data(new_pos) = go_ahead( pos = pos dir = dir ).
    if map->check_in_bounds( new_pos ).
        if     map->get_by_v2(  new_pos ) eq '.'
            or map->get_by_v2(  new_pos ) eq '^' .
            res = abap_true.
        endif.
    endif.
  endmethod.
  method go_ahead. "( pos = pos dir = dir ).
    new_pos = value #( x = pos-x + dir-x y = pos-y + dir-y ).
  endmethod.
  method turn_right. "( dir ).
    " up (0,-1) -> right (1,0)
    " right (1,0) -> down (-0,1) = (0,1)
    " down (0,1) -> left (-1, 0)
    " left (-1,0) -> up (-0, -1)
    new_dir = value #( x = ( - dir-y ) y = dir-x ). " formula every game programmer should know
  endmethod.

    method walk_around.
        data(pos) = guard_pos.
        data(dir) = value zclaoc2024_day4_matrix=>t_v2( x = 0 y = -1 ). "start going up
        while not goes_out_of_map( pos = pos dir = dir ).
            if can_go_ahead( pos = pos dir = dir ).
                append pos to trace.
                pos = go_ahead( pos = pos dir = dir ).
            else.
                dir = turn_right( dir ).
            endif.
        endwhile.
        append pos to trace.

    endmethod.

    method constructor.
       super->constructor( ).
       go_w  = value #( x = -1 y = 0 ). " <- not needed, will delete later
       go_nw = value #( x = -1 y = -1 ).
       go_n  = value #( x = 0 y = -1 ).
       go_ne = value #( x = 1 y = -1 ).
       go_e  = value #( x = 1 y = 0 ).
       go_se = value #( x = 1 y = 1 ).
       go_s  = value #( x = 0 y = 1 ).
       go_sw = value #( x = -1 y = 1 ).
    endmethod.
    method zif_aoc2024~resolve.
        " I'm going to reuse the matrix class from day 4
        " for walking around I'm also going to resuse some parts of day 4
        " hopefully this naive algrithm wont become to slow...lets see and improve later
        " make it run first.
        " Good Morning and wolkome to just another coding session of AoC 2024,Day 6!
        "    St. Nicolaus in my Part of the world
        data(lines) = split_into_lines(  puzzleinput ).
        data(rows) = lines( lines ).
        data(cols) = strlen(  lines[ 1 ] ). "" Assumption all lines have same length

        map = new #( rows = rows cols = cols ).
        loop at lines assigning field-symbol(<line>).
            data(row) = sy-tabix.
            if cols ne strlen( <line> ).
                raise exception type cx_fatal_exception.
            endif.
            " find the guard position here
            find first occurrence of `^` in <line>
                match offset data(col).
            if sy-subrc eq 0.
                " one-off error again, offset is 0-based, obviously
                data(guard_pos) = value zclaoc2024_day4_matrix=>t_v2( x = col + 1 y = row ).
            endif.
            map->put_row_from_string( content = <line> row = row ).
        endloop.
        " check guard pos...
        if map->get_by_v2( guard_pos ) ne '^'.
            raise exception type cx_fatal_exception.
        endif.

        data trace type table of zclaoc2024_day4_matrix=>t_v2 with empty key.
        walk_around( exporting map = map guard_pos = guard_pos changing trace = trace ).

        sort trace by x y.
        delete adjacent duplicates from trace comparing x y.


        data(result_part1) = lines( trace ).
        
        " thank you for watching the ABAP Solution for St. Nicolaus Part1
        " I'm going to continue couple of hours later, hope you join me than.
        
        " Bye Bye and stay coding.
        

        result = | { result_part1 }|.
    endmethod.
endclass.