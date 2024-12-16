class zclaoc2024_day15 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        V2 type zclaoc2024_day4_matrix=>t_v2,
        MoveKind type char1,
        begin of t_map_tile,
            pos type V2,
            kind type char1,
        end of t_map_tile,
        tt_map type hashed table of t_map_tile with unique key pos,
        tt_movement type standard table of char1 with empty key.
    data:
        robot_pos type V2,
        tiles type tt_map,
        movements type tt_movement,
        map type ref to zclaoc2024_day4_matrix.
    methods:
        read_puzzle importing puzzleinput type string,
        symbol_to_dir importing mov type char1 returning value(dir) type V2,
        walk_the_robot,
        move importing mov type char1 item_at_pos type V2,
        look_ahead importing pos type V2 mov type char1 returning value(new_pos) type V2,
        try_go importing pos type V2 move type MoveKind do_it type abap_bool returning value(can_do) type abap_bool,
        print_map returning value(res) type string,
        calculate_gps returning value(gps) type i.
endclass.



class zclaoc2024_day15 implementation.
    method print_map.
        res = ||.
        do map->rows times.
            data(y) = sy-index.
            do map->cols times.
                data(x) = sy-index.
                data(ch) = map->get( x = x y = y ).
                res = res && ch.
            enddo.
            res = |{ res }\n|.
         enddo.
    endmethod.
    method read_puzzle.
        data(lines) = split_into_lines( puzzleinput ).
        data(reading_mode) = 'map'.
        data row type i.
        data(rows) = 0.
        data(cols) = 0.
        loop at lines assigning field-symbol(<line>).

            if reading_mode eq 'map'.
               cols = strlen( <line> ).
               find all occurrences of regex `[#O@\.]` in <line> results data(matches).
               if sy-subrc ne 0.
                rows = row.
                reading_mode = 'mov'.
               else.
                   row = sy-tabix.
                   loop at matches assigning field-symbol(<m>).
                        data(col) = <m>-offset + 1.
                        data(pos) = value V2( x = col y = row ).
                        data(kind) = <line>+<m>-offset(<m>-length).
                       case kind.
                        when '#' or '.' or 'O'.
                        when '@'. robot_pos = pos.
                       endcase.
                      insert value #( pos = pos kind = kind ) into table tiles.
                   endloop.
               endif.
            endif.

            if reading_mode eq 'mov'.
                find all occurrences of regex `[<>^v]` in <line> results matches.
                if sy-subrc ne 0.
                    raise exception type cx_fatal_exception.
                endif.
                loop at matches assigning <m>.
                    append <line>+<m>-offset(<m>-length) to movements.
                endloop.
            endif.

        endloop.

        map = new #( rows = rows cols = cols ).
        loop at tiles assigning field-symbol(<tile>).
            map->put( x = <tile>-pos-x y = <tile>-pos-y v = <tile>-kind ).
        endloop.

    endmethod.

    method symbol_to_dir.
        case mov.
            when '<'. dir = value V2(  x = -1 y = 0 ).
            when '>'. dir = value V2(  x = +1 y = 0 ).
            when '^'. dir = value V2(  x = 0 y = -1 ).
            when 'v'. dir = value V2(  x = 0 y = +1 ).
        endcase.
    endmethod.

    method look_ahead.
        data(dir) = symbol_to_dir( mov ).
        new_pos = value V2( x = pos-x + dir-x y = pos-y + dir-y ).
    endmethod.

    method try_go. " importing pos type V2 move type MoveKind do_it type abap_bool returning value(can_do) type abap_bool,
        data(new_pos) = look_ahead( pos = pos mov = move ).
        data(cur_tile) = map->get_by_v2( pos = pos ).
        data(next_tile) = map->get_by_v2( pos = new_pos ).
        if  next_tile eq '#'.
            can_do = abap_false.
            exit.
        endif.

        if next_tile ne '.'.
            can_do = try_go( pos = new_pos move = move do_it = do_it ).
        else.
            can_do = abap_true.
        endif.
        if can_do eq abap_true and do_it eq abap_true.
            " @OOO. -> @OO.O -> @O.OO -> @.OOO -> .@OOO
            data(aux) = map->get_by_v2( pos = new_pos ).
            map->put_by_v2( pos = new_pos v = cur_tile ).
            map->put_by_v2( pos = pos v = aux ).
        endif.

    endmethod.

    method move.
        " i have to decide if working with map or with tile table....
        " i opt for map from now on
        data(item) = map->get_by_v2( pos = item_at_pos ).
        case item.
            when '@'. " ROBOT
                "if try_go( pos = item_at_pos move = mov do_it = abap_false ) eq abap_true.
                    " possibly you must check if you have to push some crates away
                    if try_go( pos = item_at_pos move = mov do_it = abap_true ) eq abap_true.
                        robot_pos = look_ahead( pos = robot_pos mov = mov ).
                    endif.
                "endif.
            when 'O'. " Crate -> pushing crates its the game of sokoban for the older ones..
            when others.
                "do nothing
        endcase.
    endmethod.

    method walk_the_robot.
       loop at movements assigning field-symbol(<mov>).
        move( mov = <mov> item_at_pos = robot_pos ).
       endloop.
    endmethod.
    method calculate_gps.
        gps = 0.
        do map->rows times.
            data(y) = sy-index.
            do map->cols times.
                data(x) = sy-index.
                if map->get(  x = x y = y ) eq 'O'.
                    gps = gps + 100 * ( y - 1 ) + ( x - 1 ).
                endif.
            enddo.
        enddo.
    endmethod.
    method zif_aoc2024~resolve.
    " Ideas:
    " read map into Matrix structure from Day 4
    " read movement sequence into an array
    " perform the movements according to the rules <-- will need some longly coding in ABAP
    " calculate the final sum

    " Part 1
        read_puzzle( puzzleinput ).

        " restarting, welcome again
        " off screen I improved the output of my tester slightly
        " and immidiatelly found an error...

        walk_the_robot(  ).
        data(result_part1) = calculate_gps(  ).
        
        
        " Part 2
        " by bye for now i'm going to continue in the evening, 
        " hope you enjoyed coding with me until now
        " have a nice sunday and keep coding...

        result = | Part 1: gps = { result_part1 }\n{ print_map( ) }|.
    endmethod.
endclass.