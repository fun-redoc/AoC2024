class zclaoc2024_day9 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .


  public section.
    interfaces if_oo_adt_classrun .
    methods:
             zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_disc_map_entry,
            kind type char1, " . for space, digit for data (block len)
            id type i,
            cnt type i,
            start type i,
            end of t_disc_map_entry,
        tt_disc_map type table of t_disc_map_entry with empty key,
        begin of t_disc_state,
            disc_map type tt_disc_map,
            spaces type table of t_disc_map_entry with empty key,
            files type table of t_disc_map_entry with empty key,
        end of t_disc_state.
    methods:
        to_string importing disc_map type tt_disc_map
                   returning value(s) type string,
         make_disk_map_from_puzzleinput importing puzzleinput type string
                                        returning value(disc_state) type t_disc_state,
        compactify changing disc_map type tt_disc_map,
        compactify2 importing disc_state type t_disc_state returning value(compact_disc_map) type tt_disc_map,
        calculate_checksum importing disc_map type tt_disc_map
                           returning value(checksum) type int8,
        part_2 importing puzzleinput type string returning value(result) type string,
        part_1 importing puzzleinput type string returning value(result) type string.

ENDCLASS.



CLASS ZCLAOC2024_DAY9 IMPLEMENTATION.


    method calculate_checksum.
        checksum = 0.
        data(pos) = 0.
        loop at disc_map assigning field-symbol(<entry>).
           if <entry>-kind ne '.'.
               checksum = checksum + <entry>-id * ( pos ).
           endif.
           add 1 to pos.
        endloop.
    endmethod.


    method compactify.
        " idea
        " start from right and left simultanously
        " stop at . from left and not . from right
        " swap
        " and repeat

        data(ridx) = lines(  disc_map ).
        data(lidx) = 1.
        data(ready) = abap_false.
        while ready ne abap_true.
            if disc_map[ ridx ]-kind ne '.' and disc_map[ lidx ]-kind eq '.'.
                "swap
                data(tmp) = disc_map[ lidx ].
                disc_map[ lidx ] = disc_map[ ridx ].
                disc_map[ ridx ] = tmp.
            endif.
            if disc_map[ lidx ]-kind ne '.'.
                add 1 to lidx.
            endif.
            if disc_map[ ridx ]-kind eq '.'.
                subtract 1 from ridx.
            endif.
            if lidx >= ridx.
                ready = abap_true.
            endif.
        endwhile.
    endmethod.


    method compactify2.
        data(spaces) = disc_state-spaces.
        data(files) = disc_state-files.
        compact_disc_map = disc_state-disc_map.
        data(idx_space) = 1.
        data(idx_file) = lines(  files ).

        while idx_file gt 0.
            data(file) = files[ idx_file ].
            data(do_swap) = abap_false.
            while  idx_space lt lines( spaces ).
                if spaces[ idx_space ]-start > file-start.
                    do_swap = abap_false.
                    exit.
                endif.
                if spaces[ idx_space ]-cnt >= file-cnt.
                    do_swap = abap_true.
                    exit.
                endif.
                add 1 to idx_space.
            endwhile.
            "
            if do_swap eq abap_true. "
                data(delta) = spaces[ idx_space ]-cnt - file-cnt.
                do file-cnt times.
                    data(idx) = sy-index.
                    data(compact_space_idx) = spaces[ idx_space ]-start + idx - 1.
                    data(compact_file_idx) = file-start + idx - 1.
                    data(aux) = compact_disc_map[ compact_file_idx ].
                    compact_disc_map[ compact_file_idx ] = compact_disc_map[ compact_space_idx ].
                    compact_disc_map[ compact_space_idx ] = aux.
                enddo.
                spaces[ idx_space ]-cnt = spaces[ idx_space ]-cnt - file-cnt.
                if spaces[ idx_space ]-cnt eq 0.
                    delete spaces index idx_space.
                else.
                    spaces[ idx_space ]-start = spaces[ idx_space ]-start + file-cnt.
                endif.
            endif.
            idx_space = 1.
            subtract 1 from idx_file.
        endwhile.
    endmethod.


    method if_oo_adt_classrun~main.
        " This could be a nice testin method
        " unfortunatelly exlipse ADT stalls completty here
        data(resolver) = new zclaoc2024_day9(  ).

        data day type string.
        data puzzleinput type string.

        clear puzzleinput.
        clear day.
        select single aocday, content from zaoc2024 into ( @day, @puzzleinput ) where aoclabel = 'Day9-long'.
        "select single aocday, content from zaoc2024 into ( @day, @puzzleinput ) where id = '000000000002'.
        if sy-subrc ne 0.
            raise exception type cx_fatal_exception.
        endif.
        if puzzleinput is initial.
            raise exception type cx_fatal_exception.
        endif.

        cl_demo_output=>display( resolver->resolve( puzzleinput ) ).
    endmethod.


    method make_disk_map_from_puzzleinput.
        clear disc_state.
        data(field_id) = 0.
        find all occurrences of regex `\d`
            in puzzleinput
            results data(matches).
        loop at matches assigning field-symbol(<m>).
            if sy-tabix mod 2 eq 1. " 1 based
                "block
                data(block_cnt_c) = conv char1( puzzleinput+<m>-offset(<m>-length) ).
                data(block_cnt) = conv i( block_cnt_c ).
                append value #( kind = block_cnt_c id = field_id cnt = block_cnt start = lines( disc_state-disc_map ) + 1 ) to disc_state-files.
                do block_cnt times.
                    append value #( kind = block_cnt_c id = field_id cnt = block_cnt  ) to  disc_state-disc_map.
                enddo.
                add 1 to field_id.
            else.
                " space
                data(space_cnt) = conv i( puzzleinput+<m>-offset(<m>-length) ).
                append value #( kind = '.' id = field_id cnt = space_cnt start = lines( disc_state-disc_map ) + 1 ) to disc_state-spaces.
                do space_cnt times.
                    append value #( kind = '.' id = field_id cnt = space_cnt ) to disc_state-disc_map.
                enddo.
            endif.
        endloop.
    endmethod.



    method part_1.
        data(disc_state) = make_disk_map_from_puzzleinput( puzzleinput ).
        compactify( changing disc_map = disc_state-disc_map ).
        result = | { calculate_checksum( disc_state-disc_map ) } |.
    endmethod.


    method part_2.
        data(disc_state) = make_disk_map_from_puzzleinput( puzzleinput ).
        data(compact_disc_map) = compactify2(  disc_state ).
        result = | { calculate_checksum( compact_disc_map ) } |.
    endmethod.


    method to_string.
        s = reduce string( init acc = `` for e in disc_map next acc = acc && e-kind ).
    endmethod.


    method zif_aoc2024~resolve.
        " Part 1
        data(result_part1) = part_1( puzzleinput ).

        " Part 2
        data(result_part2) = part_2( puzzleinput ). "  6412390114238

        result = |  Part 1 { result_part1 },  Part 2: { result_part2 }|.
    endmethod.
ENDCLASS.