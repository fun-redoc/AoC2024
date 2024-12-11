class zclaoc2024_day11 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        tt_stones type standard table of int8 with empty key,
        begin of t_puzzle,
            blinks type int8,
            initial type tt_stones,
            final type tt_stones,
        end of t_puzzle,
        begin of t_pair,
            fst type int8,
            snd type int8,
        end of t_pair,
        begin of t_memo,
            s type int8,
            positions type i,
            fst type int8,
            snd type int8,
        end of t_memo,
        tt_memo type hashed table of t_memo with unique key s.
    data:
        xmemo type tt_memo.

    methods:
        " try memoizing...
        to_string importing stones type tt_stones returning value(res) type string,
        number_of_digits importing s  type int8 returning value(cnt) type i,
        has_even_number_of_digits importing s  type int8 returning value(res) type abap_bool,
        split_in_half importing s type int8 returning value(pair) type t_pair,
        blink_stones importing stones type tt_stones returning value(after) type tt_stones,
        read_puzzle importing puzzleinput type string returning value(puzzle) type t_puzzle,
        solve_part1 changing puzzle type t_puzzle.
endclass.


class zclaoc2024_day11 implementation.
    method read_puzzle.
        find first occurrence of regex `Blinks:(\d+)` in puzzleinput submatches data(blinks)
            match offset data(off) match length data(len).
        if sy-subrc ne 0.
            raise exception type cx_fatal_exception.
        endif.
        puzzle-blinks = conv i(  blinks ).
        data(new_start) = off + len.
        data(remainding) = puzzleinput+new_start.
        find all occurrences of regex `(\d+)` in remainding results data(matches).
        puzzle-initial = value tt_stones( for match in matches ( conv int8( remainding+match-offset(match-length) ) ) ).
    endmethod.

    method number_of_digits.
        data(rem) = s.
        cnt = 0.
        while rem > 0.
            add 1 to cnt.
            rem = rem div 10.
        endwhile.
    endmethod.

    method has_even_number_of_digits.
        if number_of_digits( s ) mod 2 eq 0.
            res = abap_true.
        else.
            res = abap_false.
        endif.
    endmethod.

    method split_in_half .
        data(cnt) = number_of_digits( s ).
        data(aux) = s.
        data acc type standard table of i with empty key.
        do cnt times.
            data(idx) = sy-index.
            append (  aux mod 10 ) to acc.
            aux = aux div 10.
        enddo.
        " now acc consists of the number in reverse
        idx = 1.
        pair-fst = 0.
        do cnt div 2 times.
            pair-fst = pair-fst * 10 +  acc[ lines( acc ) - idx + 1 ].
            add 1 to idx.
        enddo.
        pair-snd = 0.
        do cnt div 2 times.
            pair-snd = pair-snd * 10 +  acc[ lines( acc ) - idx + 1  ].
            add 1 to idx.
        enddo.
        " i (int type) skips leading 0 automatically
        insert value t_memo( s = s positions = cnt fst = pair-fst snd = pair-snd ) into table me->xmemo .
    endmethod.

    method blink_stones.
    " 1. If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
    " 2. If the stone is engraved with a number that has an even number of digits,
    "    it is replaced by two stones. The left half of the digits are engraved on the new left stone,
    "    and the right half of the digits are engraved on the new right stone.
    "    (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
    " 3. If none of the other rules apply, the stone is replaced by a new stone;
    "    the old stone's number multiplied by 2024 is engraved on the new stone.
        loop at stones into data(s).
            if s eq 0.
                append 1 to after.
            else.
                read table me->xmemo with key s = s assigning field-symbol(<memo>).
                if <memo> is assigned.
                    append <memo>-fst to after.
                    append <memo>-snd to after.
                else.
                    if has_even_number_of_digits( s ) eq abap_true.
                        data(pair) = split_in_half( s ).
                        append pair-fst to after.
                        append pair-snd to after.
                    else.
                        append s * 2024 to after.
                    endif.
                endif.
            endif.
        endloop.
    endmethod.
    method solve_part1.
        data(stones_after_blink) = puzzle-initial.
        do puzzle-blinks times.
            data(blink) = sy-index.

            stones_after_blink = blink_stones( stones_after_blink ).

        enddo.
        puzzle-final = stones_after_blink.

    endmethod.
    method to_string.
        loop at stones into data(s).
            res = res && `.` && s.
        endloop.
    endmethod.
    method zif_aoc2024~resolve.
        data(puzzle) = read_puzzle( puzzleinput ).
        solve_part1( changing puzzle = puzzle ).
        data(result_part1) = lines( puzzle-final ).
        "result = | Part 1: { result_part1 }  ---> { to_string( puzzle-final ) }|.
        result = | Part 1: { result_part1 } |.
    endmethod.
endclass.