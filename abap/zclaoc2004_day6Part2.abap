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
        tt_ray type table of zclaoc2024_day4_matrix=>t_v2 with empty key,
        tt_obstacles type table of zclaoc2024_day4_matrix=>t_v2 with empty key,
        begin of t_trace,
            pos type zclaoc2024_day4_matrix=>t_v2,
            step type c length 1, " one of A for ahead, R for right
            dir type zclaoc2024_day4_matrix=>t_v2,
        end of t_trace,
        tt_trace type table of t_trace.
        data:
            map type ref to zclaoc2024_day4_matrix.
        methods:
            shoot_a_ray_to_outside importing
                                       pos type zclaoc2024_day4_matrix=>t_v2
                                       dir type zclaoc2024_day4_matrix=>t_v2
                             returning value(res) type abap_bool,
            find_obstacles importing trace type tt_trace
                            returning value(new_obstacles) type tt_obstacles,
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
  method shoot_a_ray_to_outside.
    " go ahead and collect positions form trace
    " until an obstacle or leaving map
    res = abap_true.
    data(cur_pos) = pos.
    while map->check_in_bounds( cur_pos ).
        if map->get_by_v2( cur_pos ) eq '#'.
            " leaving the trace
            res = abap_false.
            exit.
        endif.
        cur_pos = go_ahead(  pos = cur_pos dir = dir ).
    endwhile.
  endmethod.

  method find_obstacles. "" ???? should I give up this approach?? have no idea
  data i_ve_been_already type tt_trace.
  data(from_dir) = value zclaoc2024_day4_matrix=>t_v2( x = 0 y = -1 ).
  loop at trace assigning field-symbol(<point>).
      data(pos) = <point>-pos.
      data(dir) = <point>-dir.
      if <point>-step eq 'A'.
          " check if I already been to the right, if so there can be a cycle, set obstacle ahead
          data(check_right_dir) = turn_right( dir ).
          data(check_pos) = go_ahead( pos = pos dir = check_right_dir ).
          read table i_ve_been_already with key pos = check_pos dir = check_right_dir transporting no fields.
          if sy-subrc eq 0. " iv been there already, an in same direction, make a cycle
              data(new_obstacle) = value zclaoc2024_day4_matrix=>t_v2( x = pos-x + dir-x y = pos-y + dir-y ).
              if map->get_by_v2( new_obstacle ) ne '#'.
                  append new_obstacle to new_obstacles.
              endif.
          else.
              " in parallel next to in parallel movement
              read table i_ve_been_already with key pos = check_pos dir = dir transporting no fields.
              if sy-subrc eq 0. " iv been there already, an in same direction, make a cycle
                  new_obstacle = value zclaoc2024_day4_matrix=>t_v2( x = pos-x + dir-x y = pos-y + dir-y ).
                  if map->get_by_v2( new_obstacle ) ne '#'.
                      append new_obstacle to new_obstacles.
                  endif.
              else.
                  " in paralle in oposite movement
                  data(oposit_dir) = value zclaoc2024_day4_matrix=>t_v2( x = - dir-x y = - dir-y ).
                  read table i_ve_been_already with key pos = check_pos dir = oposit_dir transporting no fields.
                  if sy-subrc eq 0. " iv been there already, an in same direction, make a cycle
                      " shoot ray to check if an obstacle # is going to be hit
                      if shoot_a_ray_to_outside( pos = check_pos dir = check_right_dir ) eq abap_false.
                          new_obstacle = value zclaoc2024_day4_matrix=>t_v2( x = pos-x + dir-x y = pos-y + dir-y ).
                          if map->get_by_v2( new_obstacle ) ne '#'.
                              append new_obstacle to new_obstacles.
                          endif.
                      endif.
                  else.
                      if shoot_a_ray_to_outside( pos = check_pos dir = check_right_dir ) eq abap_false.
                          " check if there is a position already passed elong the ray
                          data(ray_pos) = check_pos.
                          data(found) = 4.
                          while found ne 0 and
                                map->check_in_bounds(  ray_pos ) eq abap_true and
                                map->get_by_v2(  ray_pos ) ne '#'.
                              read table i_ve_been_already with key pos = ray_pos dir = check_right_dir transporting no fields.
                              found = sy-subrc.
                              " here we shoot a ray to find if there is already a path we have gone
                              "   gone ahead. but what if there is a position that was just a turn?
                              if found ne 0.
                                data(check_right_right_dir) = turn_right(  check_right_dir ).
                                read table i_ve_been_already with key pos = ray_pos step = 'R' dir = check_right_right_dir transporting no fields.
                                found = sy-subrc.
                              endif.
                              ray_pos = go_ahead( pos = ray_pos dir = check_right_dir ).
                          endwhile.
                          if found eq 0.
                              new_obstacle = value zclaoc2024_day4_matrix=>t_v2( x = pos-x + dir-x y = pos-y + dir-y ).
                              if map->get_by_v2( new_obstacle ) ne '#'.
                                  append new_obstacle to new_obstacles.
                              endif.
                          endif.
                      endif.
"
                  endif.
              endif.
         endif.
      endif.
      append value #(  pos = pos step = <point>-step dir = from_dir ) to i_ve_been_already.
      from_dir = dir.
  endloop.
endmethod.


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
        data step type t_trace-step value 'A'.
        while not goes_out_of_map( pos = pos dir = dir ).
            if can_go_ahead( pos = pos dir = dir ).
                append  value t_trace( pos = pos step = step dir = dir ) to trace.
                pos = go_ahead( pos = pos dir = dir ).
                step = 'A'.
            else.
                dir = turn_right( dir ).
                step = 'R'.
            endif.
        endwhile.
        append  value t_trace( pos = pos step = step dir = dir ) to trace.

    endmethod.

    method constructor.
       super->constructor( ).
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

        data trace type tt_trace.
        walk_around( exporting map = map guard_pos = guard_pos changing trace = trace ).

        data(trace1) = trace.

        sort trace1 by pos-x pos-y.
        delete adjacent duplicates from trace1 comparing pos-x pos-y.
        data(result_part1) = lines( trace1 ).

        " Hello Again, now its 9:40 PM GMT+1 of Day 6 Starting St. Nicolaus Part2
        " I havent understood the description completly by now....
        " what i undestood
        "   I have to put new obstacles where the guard has to turn right
        "   in a way that the guard gets stuck in an endless loop
        "   I have to find all position possible for those obstacles...

        " idea:
        "->  1. extend the race, to remember where the guard turned right.  A loop will consist of 4 turns...
        "  2. go the trace and check for every position in trace if you can create a loop
        "     1.2. try the following
        "            at each position where the guard is going ahead shoot a "ray" to the right
        "            if the ray meets an other turn point, than there must be a new obstacle ahaed
        "            ( not shure about this.)

        data(new_obstacles) = find_obstacles( trace = trace ).
        data(result_part2) = lines(  new_obstacles ).


" hello again....
" trying to solve Day 6 Part 2.
" last night i gave up after a wrong solution to the puzzle...
"  overnight i found just one scenario that i havent covered yet, trying and then finishing finally

" the soluition is still not complete
"  no idea how to procede by now.

        result = | Part 1: { result_part1 } Part 2: { result_part2 }|.
    endmethod.
endclass.