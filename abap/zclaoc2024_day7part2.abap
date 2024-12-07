class zclaoc2024_day7 definition
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
        tt_coefs type table of i with empty key,
        begin of t_equation,
            res type int8,
            xs type tt_coefs,
            ops type table of char1 with empty key,
        end of t_equation,
        tt_equations type table of t_equation with empty key,
        tt_ops type standard table of char1 with empty key.
    data:
        equations type tt_equations,
        ops type tt_ops.
    methods:
        concatenate_numbers importing left type int8
                                      right type i
                            returning value(res) type int8,
        calc_recursive importing tobe_res type int8
                                 coefs type tt_coefs
                                 interm_res type int8
                                 ops type tt_ops
                                 ixs type i
                       returning value(res) type int8,
        equation_can_be_valid importing equation type t_equation
                              returning value(res) type abap_bool.
ENDCLASS.



CLASS ZCLAOC2024_DAY7 IMPLEMENTATION.


    method calc_recursive.
        if ixs > lines( coefs ).
            res = interm_res.
            exit.
        endif.
        if ixs <= lines( coefs ).
            res = calc_recursive( tobe_res = tobe_res
                coefs = coefs
                interm_res = ( interm_res * coefs[ ixs ] )
                ops = ops
                ixs = ixs + 1
            ).
            if res ne tobe_res.
                res = calc_recursive( tobe_res = tobe_res
                    coefs = coefs
                    interm_res = ( interm_res + coefs[ ixs ] )
                    ops = ops
                    ixs = ixs + 1
                ).
            endif.
            if res ne tobe_res.
                res = calc_recursive( tobe_res = tobe_res
                    coefs = coefs
                    interm_res = ( concatenate_numbers( left = interm_res  right = coefs[ ixs ] ) )
                    ops = ops
                    ixs = ixs + 1
                ).
            endif.
        endif.
    endmethod.


    method concatenate_numbers.
        " 123 || 567
        res = left.
        data(reminder) = 0.
        data(quotient) = right.
        while quotient gt 0.
            reminder = quotient mod 10.
            quotient = quotient div 10.
            res = res * 10.
        endwhile.
        res = res + right.
    endmethod.


    method constructor.
        super->constructor(  ).
        ops = value #( ( '*' ) ( '+' ) ).
    endmethod.


    method equation_can_be_valid.
        " now the hard part is going to start
        data cur_ops type tt_ops.
        data interm_res type int8 value 0.

        clear cur_ops.
        interm_res = calc_recursive( tobe_res = equation-res
                                     coefs = equation-xs
                                     interm_res = conv int8( equation-xs[ 1 ] )
                                     ops = cur_ops
                                     ixs = 2 ).
        if interm_res eq equation-res.
            res = abap_true.
        else.
            res = abap_false.
        endif.
    endmethod.


    method zif_aoc2024~resolve.
    " welcome to day 7 part 1, enjoy coding with me
    " the task today looks pretty complex...
    " for me it smells like we need a backtracking solution,...,
    "  long time not programmed something alike, and never in ABAP

    " as always start with parsing the puzzle
    data(lines) = split_into_lines( puzzleinput ).
    loop at lines assigning field-symbol(<line>).
        " do it the oldstyle
        find all occurrences of regex `(\d+)`
            in <line>
            results data(matches).
        if sy-subrc ne 0.
            raise exception type cx_fatal_exception.
        endif.
        data equation type t_equation.
        loop at matches assigning field-symbol(<match>).
            if sy-tabix eq 1.
                equation-res = conv int8( <line>+<match>-offset(<match>-length) ).
            else.
                append initial line to equation-xs assigning field-symbol(<xs>).
                <xs> = conv i( <line>+<match>-offset(<match>-length) ).
            endif.
        endloop.
        append equation to equations.
        clear equation.
    endloop.

    data result_part1 type int8 value 0.
    loop at equations assigning field-symbol(<equation>).
        if equation_can_be_valid( <equation> ) eq abap_true.
            add <equation>-res to result_part1.
        endif.
    endloop.

 "   welcome to  Day 7 Part 2
 "---------------------------

    " small test
    "data(result_part2) = concatenate_numbers( left = 123 right = 568 ).

    result = | Part 2 { result_part1 }|.

    endmethod.
ENDCLASS.