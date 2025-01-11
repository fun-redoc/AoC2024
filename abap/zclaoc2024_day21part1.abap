class zclaoc2024_day21 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods :
        constructor,
        zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        V2 type zclaoc2024_day4_matrix=>t_v2,
        tt_paths type standard table of char1 with empty key,
        ttt_paths type standard table of tt_paths with empty key,
        begin of t_key_memo,
            from type V2,
            to type V2,
            paths type ttt_paths,
        end of t_key_memo,
        begin of t_seq_memo,
            seq type string,
            paths type ttt_paths,
        end of t_seq_memo,
        begin of t_pad_map,
            c type char1,
            v type V2,
            end of t_pad_map,
        tt_pad_maps type hashed table of t_pad_map with unique key c,
        begin of t_pad,
            A_pos type V2,
            map type tt_pad_maps,
            keys type ref to zclaoc2024_day4_matrix,
            move_memo type hashed table of t_key_memo with unique key from to,
            seq_memo type hashed table of t_seq_memo with unique key seq,
        end of t_pad,
        begin of t_queue_entry,
            pos type V2,
            pred type ref to data, " poointer to t_queue_entry, unfortunatelly not typed in ABAP
            key type char1,
            steps type i,
        end of t_queue_entry,
        t_keyseqs type sorted table of string with unique key table_line.
    data:
        numpad type t_pad,
        arrpad type t_pad,
        moves type tt_pad_maps.
    methods:
        num_part_of_string importing s type string returning value(res) type int8,
        shortest_sequence importing keypad_entry type string
            returning value(res) type t_keyseqs,
        get_pad_pos importing pad type t_pad
                              key type char1
                    returning value(pos) type V2,
        shortest_paths_between_two importing start type V2
                                             dest  type V2
                                    changing pad type t_pad
                                   returning value(paths) type ttt_paths,
        move_sequences importing from type char1
                                 path type string
                                 max type int8
                                 changing pad type t_pad
                       returning value(paths) type ttt_paths.

endclass.

class zclaoc2024_day21 implementation.
    method shortest_paths_between_two.
        " check momization first
        read table pad-move_memo with key from = start to = dest assigning field-symbol(<memo_entry>).
        if sy-subrc eq 0.
            paths = <memo_entry>-paths.
            exit.
        endif.

        clear paths.

        " i'm going to use bfs...
        data queue type table of t_queue_entry with empty key.
        data closed type hashed table of t_queue_entry with unique key pos.
        data min_steps type i value 9999999.

        append value #( pos = start key = 'A' steps = 0 ) to  queue.
        while lines(  queue ) > 0.
            data(cur) = queue[ 1 ].
            delete queue index 1.
            if cur-pos eq dest and cur-steps le min_steps.
                data(new_min_path) = value tt_paths(
                                                    for h = ref #( cur )
                                                    then cast t_queue_entry( h->pred )
                                                    while h is bound
                                                    ( h->key )
                                               ).
"                data new_min_path type tt_paths.
"                data(h) = ref #( cur ).
"                while h is bound.
"                    append h->key to new_min_path.
"                    h = cast t_queue_entry( h->pred ).
"                endwhile.
                if cur-steps lt min_steps.
                    clear paths.
                    min_steps = cur-steps.
                endif.
                append new_min_path to paths.

                continue.
            endif.

            insert cur into table closed.
            loop at moves assigning field-symbol(<move>).
                data(new_pos) = value V2( x = cur-pos-x + <move>-v-x y = cur-pos-y + <move>-v-y ).
                if pad-keys->check_in_bounds( new_pos ).
                    data(new_node) = value t_queue_entry( pos = new_pos
                                                          key = <move>-c
                                                          steps = cur-steps + 1
                                                          pred = new t_queue_entry( cur ) ).
                    if new_node-steps <= min_steps.
                        read table closed with key pos = new_node-pos transporting no fields.
                        if sy-subrc ne 0.
                            append new_node to queue.
                        endif.
                    endif.
                endif.
            endloop.
        endwhile.

        " memoize
        insert value #( from = start to = dest paths = paths ) into table pad-move_memo.

    endmethod.

    method get_pad_pos.
        read table pad-map with key c = key into data(pad_map).
        if sy-subrc ne 0.
            " wrong key
            raise exception type cx_fatal_exception.
        endif.
        pos = pad_map-v.
    endmethod.

    method move_sequences.
      read table pad-seq_memo with key seq = path assigning field-symbol(<memo_entry>).
      if sy-subrc eq 0.
        paths = <memo_entry>-paths.
        exit.
      endif.
      clear paths.
      if from ne 'A'.
        " movments have to start at A
        raise exception type cx_fatal_exception.
      endif.

      data(start) = get_pad_pos( pad = pad key = 'A' ).
      do strlen( path ) times.
        data(off) = sy-index - 1.
        data(key) = conv char1( path+off(1) ).
        data(dest) = get_pad_pos( pad = pad key = key ).

        " all shortrest paths between this start and dest
        data(single_paths) = shortest_paths_between_two( exporting start = start dest = dest changing pad = pad  ).
        " TODO single_paths could be memoized in de method above

        " combine the pahts
        if lines(  paths ) eq 0.
          append initial line to paths.
        endif.
        data tmp_paths like paths.
        clear tmp_paths.
        loop at single_paths assigning field-symbol(<path2>).
          loop at paths into data(path1).
            if lines( path1 ) + lines( <path2> ) <= max.
                append lines of <path2> to path1.
                append path1 to tmp_paths.
            endif.
          endloop.
        endloop.
        clear paths.
        paths = tmp_paths.

        start = dest.

      enddo.
      " memoize
      insert value #( seq = path paths = paths ) into table pad-seq_memo.

    endmethod.

    method constructor.
        super->constructor(  ).
        numpad-A_pos = value V2( x = 3 y = 3 ).
        arrpad-A_pos = value V2( x = 3 y = 1 ).
        data(numeric_keypad) = |789\n456\n123\n#0A|.
        data(arrows_keypad)  = |#^A\n<v>|.
        numpad-keys = new #( rows = 4 cols = 3 ).
        arrpad-keys = new #( rows = 2 cols = 3 ).
        loop at split_into_lines( numeric_keypad ) assigning field-symbol(<line>).
            data(y) = sy-tabix.
            numpad-keys->put_row_from_string( content =   <line> row = sy-tabix ).
            do strlen( <line> ) times.
                data(x) = sy-index.
                data(off) = x - 1.
                data(key) = <line>+off(1).
                data(vec) = value V2( x = x y = y ).
                insert value #( c = key v = vec ) into table numpad-map.
            enddo.
        endloop.
        loop at split_into_lines( arrows_keypad ) assigning <line>.
            y = sy-tabix.
            arrpad-keys->put_row_from_string( content =   <line> row = sy-tabix ).
            do strlen( <line> ) times.
                x = sy-index.
                off = x - 1.
                key = <line>+off(1).
                vec = value V2( x = x y = y ).
                insert value #( c = key v = vec ) into table arrpad-map.
            enddo.
        endloop.
        moves = value #(
                            ( c = '<' v = value #(  x = -1 y =  0 ) )
                            ( c = '>' v = value #(  x = +1 y =  0 ) )
                            ( c = '^' v = value #(  x =  0 y = -1 ) )
                            ( c = 'v' v = value #(  x =  0 y = +1 ) )
                            ( c = 'A' v = value #(  x =  0 y =  0 ) )
                       ).
    endmethod.

    method shortest_sequence. " importing keypad_entry
        data(move_seqs) = move_sequences( exporting from = 'A' path = keypad_entry max = 999999999 changing pad = numpad   ).
        data level1 type sorted table of string with unique key table_line.
        loop at move_seqs assigning field-symbol(<move_seq>).
            concatenate lines of <move_seq> into data(s) separated by ``.
            insert s into table level1.
        endloop.
        data min type int8 value 999999999999999.
        data level2 type sorted table of string with unique key table_line.
        loop at level1 assigning field-symbol(<l>).
            data(move_seqs_level2) = move_sequences( exporting  from = 'A' path = <l> max = min changing pad = arrpad ).
            loop at move_seqs_level2 assigning <move_seq>.
                if lines( <move_seq> ) <= min.
                    if lines( <move_seq> ) < min.
                        clear level2.
                        min = lines(  <move_seq> ).
                    endif.
                    concatenate lines of <move_seq> into s separated by ``.
                    insert s into table level2.
                endif.
            endloop.
            exit.
        endloop.

        min = 999999999999999.
        data level3 type sorted table of string with unique key table_line.
        loop at level2 assigning <l>.
            data(move_seqs_level3) = move_sequences( exporting from = 'A' path = <l> max = min changing pad = arrpad ).
            loop at move_seqs_level3 assigning <move_seq>.
                if lines( <move_seq> ) <= min.
                    if lines( <move_seq> ) < min.
                        clear level3.
                        min = lines(  <move_seq> ).
                    endif.
                    concatenate lines of <move_seq> into s separated by ``.
                    insert s into table level3.
                endif.
            endloop.
        endloop.

        res = level3.

    endmethod.

    method num_part_of_string.
        data num_string type string value ``.
        find all occurrences of regex `(\d)` in s results data(digits).
        loop at digits assigning field-symbol(<digit_match>).
            num_string = num_string && s+<digit_match>-offset(<digit_match>-length).
        endloop.
        res = conv int8( num_string ).
    endmethod.

    method zif_aoc2024~resolve.
        data(cases) = split_into_lines( puzzleinput ).
        " the text is very long
        " i'd start by
        " 1. implementing a data structure for the keypads (options: matrix, adjecence matrix, etc.
        " 2. it seems there are shortest pathes to determin, so i need a bfs implementation at least
        "    maybe supplemented by memoization
        " 3. have to reed on...
        "
        " i think i'm going to use matrix for keypdas (from day 4)
        "
        " 029A
        data dump type string.
        dump = |\n|.
        "types: tt_cases type table of string with empty key.
        "data(cases) = value tt_cases( ( `208A` ) ( `586A` ) ( `341A` ) ( `463A` ) ( `593A` ) ).
        "data(cases) = value tt_cases( ( `029A` ) ( `980A` ) ( `179A` ) ( `456A` ) ( `379A` ) ).
        "data(cases) = value tt_cases( ( `379A` ) ).
        data result_part1 type int8 value 0.
        loop at cases into data(case).
            data(res) = shortest_sequence( case ).
            data(len) = strlen( res[ 1 ] ).
            data(min_len) = reduce i( init l = 999999999999 for r in res next l =  cond i( when strlen( r ) < l then strlen( r ) else l  )  ).
            data(num_part) = num_part_of_string( case ).
            dump = |{  dump }\nlen={ len }, min_len={ min_len }, num_part={ num_part }\n|.
            result_part1 = result_part1 + len * num_part.
        endloop.



        loop at res assigning field-symbol(<l>) from 1 to 20.
            dump = |{ dump }\n{ <l> }|.
        endloop.
        DATA(esc1) = escape( val    = dump
                     format = cl_abap_format=>e_html_text ).
        " 160800 too high
        result = |Part 1: { result_part1 }\n{ dump } |.
    endmethod.
endclass.