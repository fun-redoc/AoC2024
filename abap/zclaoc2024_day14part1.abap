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
        tt_robots type standard table of t_robot with empty key,
        begin of t_puzzle,
            steps type i,
            size  type zclaoc2024_matrix=>t_v2,
            robots type tt_robots,
            end of t_puzzle.
    data:
        puzzle type t_puzzle.
    methods:
        read_puzzle importing puzzleinput type string,
        move_the_robot importing steps type i changing robot type t_robot,
        do_the_sim importing steps type i optional,
        count_the_quadrants returning value(safety_factor) type i.
endclass.

class zclaoc2024_day14 implementation.
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
    method move_the_robot.
        data(p_next) = value zclaoc2024_matrix=>t_v2( x = ( robot-p-x + steps * robot-v-x )
                                                      y = ( robot-p-y + steps * robot-v-y ) ).
        " teleporting (mod) steps
        data(pnx) = p_next-x mod puzzle-size-x.
        data(pny) = p_next-y mod puzzle-size-y.
        p_next = value zclaoc2024_matrix=>t_v2( x = pnx y = pny ).
        robot-p = p_next.
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

        result = | Part 1: { result_part1 } |.
    endmethod.
endclass.