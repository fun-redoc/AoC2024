class zclaoc2024_day22 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        tt_secret_inits type standard table of int8 with empty key.
    data:
        secret_init_tab type tt_secret_inits.
    methods:
        xor importing v1 type int8 v2 type int8 returning value(res) type int8,
        calculation importing secret type int8 returning value(next_secret) type int8,
        read_puzzle importing puzzleinput type string.
endclass.



class zclaoc2024_day22 implementation.
    method read_puzzle.
        data(lines) = split_into_lines( puzzleinput ).
        loop at lines assigning field-symbol(<line>).
            append conv int8( <line> ) to secret_init_tab.
        endloop.
    endmethod.
    method xor.
        types t_bin8 type x length 8.
        data xv1 type t_bin8.
        data xv2 type t_bin8.
        xv1 = conv t_bin8( v1 ).
        xv2 = conv t_bin8( v2 ).
        data(xres) = xv1 bit-xor xv2.
        res = conv int8( xres ).
        " issue may arise with int8 beeing negative
        " check it
        if res < 0 .
            raise exception type cx_fatal_exception.
        endif.
    endmethod.
    method calculation.
        data(step1) = secret * 64.
        data(step1mix) = xor( v1 = secret v2 = step1 ).
        data(step1prune) = step1mix mod 16777216.
        data(step2) = step1prune div 32.
        "data(step2mix) = xor( v1 = secret v2 = step2 ).
        data(step2mix) = xor( v1 = step1prune v2 = step2 ).
        data(step2prune) = step2mix mod 16777216.
        data(step3) = step2prune * 2048.
        "data(step3mix) = xor(  v1 = secret v2 = step3 ).
        data(step3mix) = xor(  v1 = step2prune v2 = step3 ).
        data(step3prune) = step3mix mod 16777216.
        next_secret = step3prune.
    endmethod.
    method zif_aoc2024~resolve.
        " seems realtivelly straight foreward
        read_puzzle( puzzleinput ).

        data result_part1 type int8 value 0.
        loop at secret_init_tab assigning field-symbol(<init>).
            data(previous_secret) = <init>.
            do 2000 times.
                data(next_secret) = calculation( previous_secret ).
                previous_secret = next_secret.
            enddo.
            add next_secret to result_part1.
        endloop.

" run out of time, will contimue with part2 later....
" bye bye for now.

        result = |Part 1: { result_part1 }|.
    endmethod.
endclass.