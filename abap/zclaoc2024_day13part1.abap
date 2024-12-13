class zclaoc2024_day13 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_lin_prog,
            " from pzzle
            a0 type i,
            b0 type i,
            c0 type i,
            a1 type i,
            b1 type i,
            c1 type i,
            " a*a0 + b*b0 = c

            " will be calculated
            a type i,
            b type i,
            solvable type abap_bool,
            cost type i,
            " 3*a + 1*b = cost <- what is to minimize
        end of t_lin_prog,
        tt_lin_progs type standard table of t_lin_prog with empty key.
    data:
        lin_progs type tt_lin_progs.
    methods:
        try_solve importing a type i b type i lp type t_lin_prog returning value(solvable) type abap_bool,
        calc_cost importing a type i b type i returning value(cost) type i,
        brute_force changing lp type t_lin_prog,
        read_puzzle importing puzzleinput type string.
ENDCLASS.



CLASS ZCLAOC2024_DAY13 IMPLEMENTATION.


    method brute_force.
        data(min_cost) = 99999999 .
        data(min_a) = 0.
        data(min_b) = 0.
        data(lp_solvable) = abap_false.
        do 100 times.
            data(a) = sy-index + 1.
            do 100 times.
                data(b) = sy-index + 1.
                data(solvable) = try_solve( a = a b = b lp = lp ).
                if solvable eq abap_true.
                    data(cost) = calc_cost( a = a b = b ).
                    if cost < min_cost.
                        min_a = a.
                        min_b = b.
                        min_cost = cost.
                        lp_solvable = abap_true.
                    endif.
                endif.
            enddo.
        enddo.
        if lp_solvable eq abap_true.
            lp-solvable = abap_true.
            lp-a = min_a.
            lp-b = min_b.
            lp-cost = min_cost.
        else.
            lp-solvable = abap_false.
        endif.
    endmethod.


    method calc_cost.
        cost = 3 * a + b.
    endmethod.


    method read_puzzle.
        find all occurrences of regex `(\d+)`
            in puzzleinput
            results data(matches).
        loop at matches assigning field-symbol(<match>).
            data(cnt) = sy-tabix - 1 .
            data(s) = puzzleinput+<match>-offset(<match>-length).
            data(ival) = conv i( s ).
            case cnt mod 6.
                when 0. data(a0) = ival.
                when 1. data(a1) = ival.
                when 2. data(b0) = ival.
                when 3. data(b1) = ival.
                when 4. data(c0) = ival.
                when 5. data(c1) = ival.
            endcase.
            if cnt mod 6 eq 5.
                append value #( a0 = a0 b0 = b0 c0 = c0 a1 = a1 b1 = b1 c1 = c1 ) to lin_progs.
            endif.
        endloop.

    endmethod.


    method try_solve.
        data(s0) = a * lp-a0 + b * lp-b0.
        if s0 ne lp-c0.
            solvable = abap_false.
            exit.
        endif.
        data(s1) = a * lp-a1 + b * lp-b1.
        if s1 ne lp-c1.
            solvable = abap_false.
            exit.
        endif.
        solvable = abap_true.
    endmethod.


    method zif_aoc2024~resolve.
        " basic Ideas
        "  the task in part 1 is to solve a bunch of linear optimization problems
        "  you can test one in wolfram alpha, check input "minize 3a+b subject to 94a + 22b = 8400, 34a +67b = 5400"
        "  ---> issues:
        "       1. i can't implement simplex algorithm by hart
        "       2. even simplex will often not delliver an integer result so you will have to search a solution space anyway
        "          or the puzzles are made up to have guarnties integer solutions?
        " may be the " <= 100 " contraint will allow for a brute force solution?

        " ok lets start with brute forcing...
        "
        " no chance bruteforcin part 2
        " I have to think,.. should i implement simplex or is there another hint in the puzzle i overlloked.
        " see you later in Part 2...

        read_puzzle( puzzleinput ).

        loop at lin_progs assigning field-symbol(<lp>).
            brute_force( changing lp = <lp> ).
        endloop.

        data(total_tokens1) = reduce i( init t = 0
                                       for lp in lin_progs
                                           next t = t + cond i( when lp-solvable = abap_true then lp-cost ) ).

        result = | Part 1: { total_tokens1 }|.
    endmethod.
ENDCLASS.