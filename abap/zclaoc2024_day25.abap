class zclaoc2024_day25 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        tt_heights type standard table of i with empty key,
        ttt_heights type standard table of tt_heights with empty key,
        begin of t_pair,
            hash_key type i,
            hash_lock type i,
            key type tt_heights,
            lock type tt_heights,
        end of t_pair,
        tt_pairs type hashed table of t_pair with unique key hash_key hash_lock.
    data:
        keys type ttt_heights,
        locks type ttt_heights.
    methods:
        hashes_for_pair changing pair type t_pair,
        read_puzzle importing puzzleinput type string,
        solve_part1 returning value(res) type string.
endclass.



class zclaoc2024_day25 implementation.
    method hashes_for_pair.
        data(hash_key) = reduce i( init h = 0 d = 1 for k in pair-key next h = h + k * d d = 10 * d ).
        data(hash_lock) = reduce i( init h = 0 d = 1 for k in pair-lock next h = h + k * d d = 10 * d ).
        pair-hash_key = hash_key.
        pair-hash_lock = hash_lock.
    endmethod.
    method read_puzzle.
        data current type char1.
        clear current.
        data(lines) = split_into_lines( puzzleinput ).
        loop at lines assigning field-symbol(<line>).
            data(cnt) = sy-tabix - 1.
            if <line> eq `#####`  and cnt mod 7 eq 0.
               append initial line to locks assigning field-symbol(<contraption>).
               do 5 times.
                append 0 to <contraption>.
               enddo.
               current = 'L'.
            elseif <line> eq `.....` and cnt mod 7 eq 6.
                clear current.
            elseif <line> eq `.....` and cnt mod 7 eq 0.
               append initial line to keys assigning <contraption>.
               do 5 times.
                append 0 to <contraption>.
               enddo.
               current = 'K'.
            elseif <line> eq `#####` and cnt mod 7 eq 6.
                clear current.
            else.
                find all occurrences of regex `([\.#])` in <line> results data(matches).
                loop at matches assigning field-symbol(<m>).
                    data(pos) = sy-tabix.
                    data(off) = pos - 1.
                    <contraption>[ pos ] = <contraption>[ pos ] + cond i( when <line>+off(1) eq '#' then 1 else 0 ).
                endloop.
            endif.
        endloop.
    endmethod.
    method solve_part1.
        data pairs type tt_pairs.
        loop at keys assigning field-symbol(<key>).
            loop at locks assigning field-symbol(<lock>).
                data(overlap) = abap_false.
                do 5 times.
                    if <lock>[ sy-index ] + <key>[ sy-index ] > 5.
                        overlap = abap_true.
                        exit.
                    endif.
                enddo.
                if overlap ne abap_true.

                    data(pair) =  value t_pair(  key = <key> lock = <lock> ).
                    hashes_for_pair(  changing pair = pair ).
                    insert pair into table pairs.
                endif.
            endloop.
        endloop.

        res = |{ lines( pairs ) }|.
    endmethod.
    method zif_aoc2024~resolve.
        "Part 1:
        " at least part 1 seems to be relativelly straight foreward probing all combinations...

        read_puzzle(  puzzleinput ).

        data(result_part1) = solve_part1(  ).

        " not having enough stars to start Part2 I say good bye for now,
        " marry christmas and stay coding...

        result = |Part 1:{ result_part1 }|.
    endmethod.

endclass.