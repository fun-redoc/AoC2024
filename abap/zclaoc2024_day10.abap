class zclaoc2024_day10 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
       tt_pos type table of zclaoc2024_day4_matrix=>t_v2 with empty key.
    data: map type ref to zclaoc2024_day4_matrix.
    methods:
        go_up importing pos type zclaoc2024_day4_matrix=>t_v2
                returning value(next_pos) type zclaoc2024_day4_matrix=>t_v2,
        go_left importing pos type zclaoc2024_day4_matrix=>t_v2
                returning value(next_pos) type zclaoc2024_day4_matrix=>t_v2,
        go_right importing pos type zclaoc2024_day4_matrix=>t_v2
                returning value(next_pos) type zclaoc2024_day4_matrix=>t_v2,
        go_down importing pos type zclaoc2024_day4_matrix=>t_v2
                returning value(next_pos) type zclaoc2024_day4_matrix=>t_v2,
        read_topo_map importing puzzleinput type string
                      returning value(trailheads) type tt_pos,
        count_full_trails importing score_type type char1
                                     trailhead type zclaoc2024_day4_matrix=>t_v2
                            returning value(cnt_fulltrails) type i,
        count_full_trails_rec importing score_type type char1
                                        map type ref to zclaoc2024_day4_matrix
                                        pos type zclaoc2024_day4_matrix=>t_v2
                                        last_height type i
                            returning value(cnt_fulltrails) type i.
endclass.



class zclaoc2024_day10 implementation.
    method go_up.
        next_pos = value #( x = pos-x y = pos-y - 1 ).
    endmethod.
    method go_left.
        next_pos = value #( x = pos-x - 1 y = pos-y  ).
    endmethod.
    method go_down.
        next_pos = value #( x = pos-x y = pos-y + 1 ).
    endmethod.
    method go_right.
        next_pos = value #( x = pos-x + 1 y = pos-y ).
    endmethod.
    method read_topo_map.
        data(lines) = split_into_lines( puzzleinput ).
        data(rows) = lines(  lines ).
        data(cols) = strlen( lines[ 1 ] ).
        map = new #( rows = rows cols = cols  ).
        loop at lines assigning field-symbol(<line>).
           data(row) = sy-tabix.
           map->put_row_from_string( row = row content = <line> ) .
           find all occurrences of `0` in <line> results data(matches).
           loop at matches assigning field-symbol(<match>).
               data(head_col) = <match>-offset + 1. "" offset is 0 based, pos 1 based
               append value zclaoc2024_day4_matrix=>t_v2( x = head_col y = row ) to trailheads.
           endloop.
        endloop.
    endmethod.
    method count_full_trails_rec.
        if map->check_in_bounds( pos ) eq abap_false.
            cnt_fulltrails = 0.
            exit.
        endif.
        data(pos_height) = map->get_by_v2( pos ).
        if strlen( match( val = pos_height regex = `[0-9]` ) ) eq 0.
            cnt_fulltrails = 0.
            exit.
        endif.
        data(i_pos_height) = conv i(  pos_height ).
        if i_pos_height ne last_height + 1.
            cnt_fulltrails = 0.
            exit.
        endif.
        if score_type eq 'S'.
            map->put(  x = pos-x y = pos-y v = '*' ). " mark as visited
        endif.
        if pos_height eq 9.
            cnt_fulltrails = 1.
            exit.
        endif.
        cnt_fulltrails = cnt_fulltrails + count_full_trails_rec( score_type = score_type map = map pos = go_up( pos ) last_height = i_pos_height ).
        cnt_fulltrails = cnt_fulltrails + count_full_trails_rec( score_type = score_type map = map pos = go_left( pos ) last_height = i_pos_height  ).
        cnt_fulltrails = cnt_fulltrails + count_full_trails_rec( score_type = score_type map = map pos = go_down( pos ) last_height = i_pos_height   ).
        cnt_fulltrails = cnt_fulltrails + count_full_trails_rec( score_type = score_type map = map pos = go_right( pos ) last_height = i_pos_height   ).
      " can there be loops?? I think no.1^
    endmethod.
    method count_full_trails.
        " I think this has to be done recursivelly
        data(aux_map) = map->clone(  ).
        cnt_fulltrails = count_full_trails_rec( score_type = score_type map = aux_map pos = trailhead last_height = -1 ).
        free aux_map.
    endmethod.
    method zif_aoc2024~resolve.
    " starts at height 0, ends at height 9,
    " and always increases by a height of exactly 1 at each step
    " only up, down, left, or right
    " trail head starts at 0 height
    " determin all full_trails (0->9) for all trailheads
    " a trailheads score is the number of full_trais for the resp. trailhead
    " Result Part1 sum of the scores of the trailheads

    data(result_part1) = 0.
    data(result_part2) = 0.
    data(trailheads) = read_topo_map( puzzleinput ).
    loop at trailheads assigning field-symbol(<trailhead>).
        data(cnt_full_trails) = count_full_trails( score_type = 'S' trailhead = <trailhead> ).
        add cnt_full_trails to result_part1.
    endloop.
    loop at trailheads assigning <trailhead>.
        data(cnt_distinct_trails) = count_full_trails( score_type = 'D' trailhead = <trailhead> ).
        add cnt_distinct_trails to result_part2.
    endloop.

    result = | Part 1: { result_part1 } Part 2: { result_part2 }|.
    endmethod.
endclass.