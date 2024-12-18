class zclaoc2024_day18 definition
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
          begin of v2,
              x type i,
              y type i,
          end of v2,
          begin of t_path_entry,
            pos type V2,
            pred type ref to data, "" may i should put this into a class like java... but lets try it this way
            is_first type abap_bool,
            gone type i,
            togo type i,
            estim type i,
          end of t_path_entry,
          begin of t_prio_entry,
              prio type i,
              entry type t_path_entry,
          end of t_prio_entry,
          tt_path type standard table of V2 with empty key,
          tt_dirs type standard table of V2 with empty key,
          tt_queue type sorted table of t_prio_entry with non-unique key prio.
    data:
        rows type i,
        cols type i,
        bytes_to_take type i,
        memory type ref to zclaoc2024_day4_matrix,
        memory_part2 type ref to zclaoc2024_day4_matrix,
        queue type tt_queue,
        bytes type standard table of V2 with empty key.
    methods:
        enq importing prio type i entry type t_path_entry,
        deq exporting entry type t_path_entry returning value(success) type abap_bool,
        manhattan importing start type V2 end type V2 returning value(dist) type i,
        astar importing mem type ref to zclaoc2024_day4_matrix start type V2 end type V2 returning value(short_path) type tt_path,
        dump importing mem type ref to zclaoc2024_day4_matrix path type tt_path optional returning value(s) type string,
        read_puzzle importing puzzleinput type string take type i.
ENDCLASS.



CLASS ZCLAOC2024_DAY18 IMPLEMENTATION.


    method astar.
        data(dirs) = value tt_dirs(
                                    ( value V2( x =  1 y =  0 ) )
                                    ( value V2( x = -1 y =  0 ) )
                                    ( value V2( x =  0 y =  1 ) )
                                    ( value V2( x =  0 y = -1 ) )
                                 ). " wow what a syntax
        data finished_set type hashed table of t_path_entry with unique key pos.

        data cur type t_path_entry.
        field-symbols: <pred_entry> type t_path_entry.

        data(manh) = manhattan( start = start end = end ).
        data(start_entry) = value t_path_entry( pos = start
                                                is_first = abap_true
                                                gone = 0
                                                togo = manh
                                                estim = manh ).

        clear short_path.

        enq( prio = 0 entry = start_entry ).

        while deq( importing entry = cur ).

            if cur-pos eq end.
                " i only need the number of steps, but i think
                " it is a good idea to return the whole path.
                clear short_path.
                while cur-is_first eq abap_false.
                    insert cur-pos into short_path index 1.
                    assign cur-pred->* to <pred_entry>.
                    cur = <pred_entry>.
                    if sy-subrc ne 0.
                        " this should never happen.
                        raise exception type cx_fatal_exception.
                    endif.
                endwhile.
                insert cur-pos into short_path index 1.
" it seams that the last (end) is not counted
            endif.

            insert cur into table finished_set reference into data(rcur).

            " now try all adjacent positions, the valid ones add to queue
            loop at dirs assigning field-symbol(<dir>).

                data(next_pos) = value V2( x = cur-pos-x + <dir>-x y = cur-pos-y + <dir>-y ).

                if mem->check_in_bounds( next_pos ) eq abap_false.
                    " path runs out of bounds
                    continue.
                endif.

                if mem->get_by_v2(  next_pos  ) eq 'X'.
                    " path runs into a wall
                    continue.
               endif.

                " check if already finished (aviod cycle)
                read table finished_set with table key pos = next_pos transporting no fields.
                if sy-subrc eq 0.
                    " found -> was already here
                    continue.
                endif.

                " I need a parent or predecessor pointer to remembe the path...

                " until now this was a normal BFS, but i want a*
                " i need to compute some distance to the destination, normally we take the manhattan distance.

                data(manh_from_next_pos) = manhattan( start = next_pos end = end ).
                data(next_path_entry) = value t_path_entry( pos = next_pos
                                                           pred = rcur "subtle, but here i Need backchainig linked list of some kind
                                                           is_first = abap_false
                                                           gone = cur-gone + 1
                                                           togo = manh_from_next_pos
                                                           estim = cur-gone + manh_from_next_pos  + 1 ). "<###


                " now have to check if there is any node left in the queue
                " which has a distancce less or equal estim(ated) remainder distance
                data(shorter_paths_available) = abap_false.
                loop at queue assigning field-symbol(<entry>).
                    if <entry>-entry-pos eq next_path_entry-pos and
                       <entry>-entry-estim le next_path_entry-estim.
                       shorter_paths_available = abap_true.
                    endif.
                endloop.
                if shorter_paths_available eq abap_true.
                    " yes, we greedely take the shortest path available.. thus not this one
                    continue.
                endif.

                " ok the new position is a candidate
                enq( prio = next_path_entry-estim entry = next_path_entry ).
            endloop.
        endwhile.
    endmethod.


    method constructor.
        super->constructor(  ).
    endmethod.


    method deq.
        if lines( queue ) gt 0.
            success = abap_true.
            entry = queue[ 1 ]-entry.
            delete queue index 1.
        else.
            success = abap_false.
            clear entry.
        endif.
    endmethod.


    method dump.
        data(memory_dump) = mem->clone(  ).
        if path is supplied.
            loop at path assigning field-symbol(<pos>).
                memory_dump->put_by_v2( pos = <pos> v = 'O' ).
            endloop.
        endif.
        s = ||.
        do rows times.
            data(r) = sy-index.
            do cols times.
                data(c) = sy-index.
                data(v) = memory_dump->get( x = c y = r ).
                if v ne space.
                    s = s && v.
                else.
                    s = s && '.'.
                endif.
            enddo.
            s = s && |\n|.
       enddo.
    endmethod.


    method enq.
        insert value t_prio_entry( prio = prio entry = entry ) into table queue.
    endmethod.


    method manhattan.
        dist = abs( start-x - end-x ) + abs( start-y - end-y ).
 "maybe euclidian
"        data(dx) = start-x - end-x.
"        data(dy) = start-y - end-y.
"        dist = dx * dx + dy * dy.
    endmethod.


    method read_puzzle.
        data(lines) = split_into_lines(  puzzleinput ).
        data(cnt_bytes) = 0.
        loop at lines assigning field-symbol(<line>).
            find first occurrence of regex `(\d+),(\d+)` in <line> submatches data(x) data(y).
            data(ix) = conv i( x ) + 1.  " make every thing 1 based, beware if reading the quest
            data(iy) = conv i( y ) + 1.
            if cnt_bytes < take.
                memory->put( x = ix y = iy v = 'X' ).
            endif.
            append value V2( x = ix y = iy ) to bytes.
            add 1 to cnt_bytes.
        endloop.
    endmethod.


    method zif_aoc2024~resolve.
        " Idea:
        " this sound like just another graph minimal path seacht
        " problem, or doesn't it?
        " I'm not sure if normal BSF is enough, or I should opt
        " for Dijkstra or A*....both need a priority queue
        " ....I need a queue anyway, why not implementing a simple prio-q

        "test example
        "bytes_to_take = 12. rows = 7. cols = 7.
        bytes_to_take = 1024. rows = 71. cols = 71.
        memory = new #( rows = rows cols = cols ).

        " now read the puzzle
        read_puzzle( puzzleinput =  puzzleinput  take = bytes_to_take ).


        data(shortest_path) = astar( mem = memory start = value V2( x = 1 y = 1 ) end = value V2( x = cols y = rows ) ).
        data(shortest_path_part1) = shortest_path.

        memory_part2 = memory->clone( ).
        data(blocked) = abap_false.
        data(remaining_bytes) = lines( bytes ) - bytes_to_take.
        do remaining_bytes times.
            data(new_byte_idx) =  bytes_to_take + sy-index .
            data(new_byte_pos) = bytes[ new_byte_idx ].
            memory_part2->put_by_v2( pos = new_byte_pos v = 'X' ).
            shortest_path = astar( mem = memory_part2 start = value V2( x = 1 y = 1 ) end = value V2( x = cols y = rows ) ).
            if lines(  shortest_path ) eq 0.
                blocked = abap_true.
                data(blocking_idx) = new_byte_idx.
                data(blocking_pos) = new_byte_pos.
                exit.
            endif.
        enddo.

        if blocked eq abap_true.
            result = |Part 1: { lines( shortest_path_part1 ) - 1 } | &&
                     |Part 2: blocking byte={ blocking_idx  } pos=({ blocking_pos-x - 1 },{ blocking_pos-y - 1 })| &&
                     |\n\n{ dump( mem = memory path = shortest_path_part1 ) }\n| &&
                     |\n\n{ dump( mem = memory_part2 path = shortest_path ) }\n|
                     .
        else.
            result = |Part 1: { lines( shortest_path_part1 ) - 1 } Part 2: failed\n\n{ dump( mem = memory path = shortest_path ) }\n|.
        endif.
    endmethod.
ENDCLASS.