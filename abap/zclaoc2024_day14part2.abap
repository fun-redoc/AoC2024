class zclaoc2024_day14 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_robot,
            p  type zclaoc2024_matrix=>t_v2,
            v  type zclaoc2024_matrix=>t_v2,
        end of t_robot,
        tt_robots type standard table of t_robot with key p,
        begin of t_puzzle,
            steps type i,
            size  type zclaoc2024_matrix=>t_v2,
            robots type tt_robots,
            end of t_puzzle,
        begin of t_sim_result,
            steps type i,
            success type abap_bool,
        end of t_sim_result.
    data:
        puzzle type t_puzzle.
    methods:
        read_puzzle importing puzzleinput type string,
        move_the_robot importing steps type i changing robot type t_robot,
        do_the_sim importing steps type i optional,
        count_the_quadrants returning value(safety_factor) type i,
        simulate importing max_steps type i returning value(res) type t_sim_result,
        check_tree_part importing x type i y type i returning value(res) type abap_bool,
        contains_tree_tip_alike returning value(res) type char1,
        print_field returning value(s) type string.
ENDCLASS.



CLASS ZCLAOC2024_DAY14 IMPLEMENTATION.


    method check_tree_part.
        read table puzzle-robots with key p = value zclaoc2024_matrix=>t_v2( x = x y = y ) transporting no fields.
        if sy-subrc eq 0.
            res = 'X'.
        else.
            res = '.'.
        endif.
    endmethod.


    method contains_tree_tip_alike.
        "    X
        "   XXX
        "  XXXXX
        " check for every robot if it is a tip of a christmas tree
            res = abap_false.
        loop at puzzle-robots assigning field-symbol(<robot>).
            data(x) = <robot>-p-x.
            data(y) = <robot>-p-y.
               " first row
            if   check_tree_part( x = x - 2 y = y ) eq '.' and
                 check_tree_part( x = x - 1 y = y ) eq '.' and
                 check_tree_part( x = x     y = y ) eq 'X' and
                 check_tree_part( x = x + 1 y = y ) eq '.' and
                 check_tree_part( x = x + 2 y = y ) eq '.' and
               " snd row
                 check_tree_part( x = x - 2 y = y + 1 ) eq '.' and
                 check_tree_part( x = x - 1 y = y + 1 ) eq 'X' and
                 check_tree_part( x = x     y = y + 1 ) eq 'X' and
                 check_tree_part( x = x + 1 y = y + 1 ) eq 'X' and
                 check_tree_part( x = x + 2 y = y + 1 ) eq '.' and
               " thrd row
                 check_tree_part( x = x - 2 y = y + 2 ) eq 'X' and
                 check_tree_part( x = x - 1 y = y + 2 ) eq 'X' and
                 check_tree_part( x = x     y = y + 2 ) eq 'X' and
                 check_tree_part( x = x + 1 y = y + 2 ) eq 'X' and
                 check_tree_part( x = x + 2 y = y + 2 ) eq 'X' .
              "
              res = abap_true.
              exit. "the loop
              "
            endif.
           " critial part
        endloop.


    endmethod.


    method count_the_quadrants.
        data quadrant_counts type standard table of i with empty key.
        append 0 to quadrant_counts.
        append 0 to quadrant_counts.
        append 0 to quadrant_counts.
        append 0 to quadrant_counts.

        data(diag_x) = puzzle-size-x div 2.
        data(diag_y) = puzzle-size-y div 2.

        loop at puzzle-robots assigning field-symbol(<robot>).
            if <robot>-p-x = diag_x or <robot>-p-y = diag_y.
                continue.
            endif.
            data(qx) = cond #( when <robot>-p-x < diag_x then 0 else 1 ) . " 0 or 1
            data(qy) = cond #( when <robot>-p-y < diag_y then 0 else 1 ). " 0 or 1 , 2 rows
            data(q_num) = 1 + ( qx + 2 * qy ).
            " quadrant 1 (top-left),
            quadrant_counts[ q_num ] = quadrant_counts[ q_num ] + 1.
        endloop.
        safety_factor = reduce i( init f = 1 for q in quadrant_counts next f = f * q ).
    endmethod.


    method do_the_sim.
       data steps_internal type t_puzzle-steps.
       if steps is not supplied.
        steps_internal = puzzle-steps.
       else.
        steps_internal = steps.
       endif.
       loop at puzzle-robots assigning field-symbol(<robot>).
         move_the_robot( exporting steps = steps_internal changing robot = <robot> ).
       endloop.
    endmethod.


    method move_the_robot.
        data(p_next) = value zclaoc2024_matrix=>t_v2( x = ( robot-p-x + steps * robot-v-x )
                                                      y = ( robot-p-y + steps * robot-v-y ) ).
        " teleporting (mod) steps
        data(pnx) = p_next-x mod puzzle-size-x.
        data(pny) = p_next-y mod puzzle-size-y.
        p_next = value zclaoc2024_matrix=>t_v2( x = pnx y = pny ).
        robot-p = p_next.
    endmethod.


    method print_field.
        data field type ref to zclaoc2024_day4_matrix.
        field = new #( cols = puzzle-size-x rows = puzzle-size-y ).
        data row type string value ``.
        do puzzle-size-y times.
            data(y) = sy-index.
            do puzzle-size-x times.
                data(x) = sy-index.
                field->put( x = x y = y v = '.' ).
            enddo.
        enddo.
        loop at puzzle-robots assigning field-symbol(<robot>).
            field->put( x = <robot>-p-x + 1 y = <robot>-p-y + 1 v = 'X' ).
        endloop.
        do puzzle-size-y times.
            y = sy-index.
            do puzzle-size-x times.
                x = sy-index.
                s = s && field->get(  x = x y = y ).
            enddo.
            s = s && '\n'.
        enddo.
    endmethod.


    method read_puzzle.
        data(lines) = split_into_lines( puzzleinput ).
        clear puzzle.

        loop at lines assigning field-symbol(<line>).
            data(line_cnt) = sy-tabix - 1.
            case line_cnt.
                when 0.
                    find first occurrence of regex `Steps: (\d+)`
                        in <line>
                        submatches data(steps).
                    if sy-subrc ne 0.
                        raise exception type cx_fatal_exception.
                    endif.
                    puzzle-steps = conv i( steps ).
                when 1.
                    find first occurrence of regex `Size:(\d+)x(\d+)`
                        in <line>
                        submatches data(cols) data(rows).
                    if sy-subrc ne 0.
                        raise exception type cx_fatal_exception.
                    endif.
                    puzzle-size = value #( x =  conv i( cols ) y = conv i( rows ) ).
                when others.
                    find first occurrence of regex `p=(\d+),(\d+) v=(-\d+|\d+),(-\d+|\d+)`
                                            in <line>
                        submatches data(px) data(py) data(vx) data(vy).
                    if sy-subrc ne 0.
                        raise exception type cx_fatal_exception.
                    endif.
                    data(p) = value zclaoc2024_matrix=>t_v2( x =  conv i( px ) y = conv i( py ) ).
                    data(v) = value zclaoc2024_matrix=>t_v2( x =  conv i( vx ) y = conv i( vy ) ).
                    append value #( p = p v = v ) to puzzle-robots.
            endcase.
        endloop.
    endmethod.


    method simulate.
        res-success = abap_false.
        res-steps = max_steps.
        do max_steps times.
            data(cur_step) = sy-index - 1.
            if contains_tree_tip_alike(  ) eq abap_true.
                res-success = abap_true.
                res-steps = cur_step.
                exit.
            else.
                do_the_sim( 1 ).
            endif.
        enddo.
    endmethod.


    method zif_aoc2024~resolve.
        " Ideas
        " 1. one can simulate the robot movement step by step, this would be the programmers fun version
        " 2. one could use some math, this would be the preparation for ovoiding performance issues later....
        "
        " so take 2.

        " Idea 2.
        " p(t_1) = p(t_0) + v mod size
        " p(t_2) = p(t_1) + v mod size = p(t_0) + v + v mod size = p(t_0) + 2v mod size etc.
        " => p(t_n) = p(t_0) * n*v mod size
        " proof by induction: p(t_n+1) = p(t_n) + v mod size  // induction step
        "                              = (p(t_o) + n*v) + v mod size
        "                              =  p(t_n) + (n+1)*v mod size // q.e.d

        " ok, lets start
" what does mod in abap really do?

        data(a) = 13 mod 11. " expect 2
        data(b) = -1 mod 11. " expect 10
        data(c) = -12 mod 11. " expect 10
        data(d) = 24 mod 11. " expect 2
        " good news abap mod works (mathematically) correct

        read_puzzle( puzzleinput ).
        do_the_sim(  ).
        data(result_part1) = count_the_quadrants(  ).

        " my time is out for today morning...
        "  and I have no Idea how a christmas tree with 500 tiles looks like or how to generate it
        "  bye bye for now, see you in Part 2 painting a christmas tree with robots.

        " hello again its 9:13 pm (GMT+1) , im going to try to solve Part 2.. enjoy coding with me.

        " since i don't know where the tree is located, how it looks etc.
        " i don't think i can solve it analytically, i could try by simulation...

        " lets simulate the robots unil a pattern arises which looks christms tree alike, something like
        "    X
        "   XXX
        "  XXXXX
        "

        clear puzzle.
        read_puzzle( puzzleinput ).
        data(max_steps) = 10000.
        data(res) = simulate( max_steps ). " max 100 steps for the start

        if res-success = abap_false.
            result = | Part 1: { result_part1 } Part 2: failed after { max_steps } secs. |.
        else.
            data(s) = print_field(  ).
            result = | Part 1: { result_part1 } Part 2: success after { res-steps } secs.\n { s } |.
        endif.
    endmethod.
ENDCLASS.