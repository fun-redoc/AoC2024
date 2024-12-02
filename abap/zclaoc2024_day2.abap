class zclaoc2024_day2 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        tt_level type standard table of i with empty key.
    methods:
        split_into_levels importing report type string returning value(levels) type tt_level,

        check_report_is_save importing levels type tt_level
                                       exclude_idx type i optional
                             returning value(report_is_save) type abap_bool,

        part1 importing report type string returning value(res) type string,
        part2 importing report type string returning value(res) type string
        .
ENDCLASS.



CLASS ZCLAOC2024_DAY2 IMPLEMENTATION.
    method check_report_is_save.
       field-symbols: <level> type i,
                      <last_level> type i.
       data direction type c value space.
       report_is_save = abap_true.
        unassign <last_level>.
        report_is_save = abap_true.
        direction = space.
        loop at levels assigning <level>. " no more expreiments!!
            if not exclude_idx is supplied or exclude_idx ne sy-tabix.
                if <last_level> is assigned.
                    if <last_level> gt <level> and ( direction eq space or direction eq 'D' ).
                        direction = 'D'.
                    elseif <last_level> lt <level> and (  direction eq space or direction eq 'A' ).
                        direction = 'A'.
                    else.
                        " equals are not counted
                        " criteria are not matched
                        report_is_save = abap_false.
                        exit.
                    endif.
                    if not abs(  <last_level> - <level> ) between 1 and 3.
                        report_is_save = abap_false.
                        exit.
                    endif.
                endif.
                assign <level> to <last_level>.
            endif.
        endloop.
    endmethod.

    method part2.
        data(lines) = split_into_lines( report ).
       " Part 2:
       "  save if a report is save or is save excluding one level
       "  => i think i must only test the second part...which implies the first

       "
       " 1 loop over the input
       " 1.1 loop over all reports
       " 1.1.1 loop over all levels
       " 1.1.2   check if report is valid without current level

       data count type i value 0.
       " Algorithm going to be O(n^2),....hopefully no performance issue...would mean timeout on the abap server.
       loop at lines assigning field-symbol(<line>).
            data(levels) = split_into_levels( <line> ).
            loop at levels assigning field-symbol(<level>).
                data(exclude_idx) = sy-tabix.
                if check_report_is_save( levels = levels exclude_idx = exclude_idx ) eq abap_true.
                    add 1 to count.
                    exit.
                endif.
            endloop.
       endloop.

        data(res_part2) = | Part 2: { count } |.
        res = res_part2.
    endmethod.
    method part1.
        data(lines) = split_into_lines( report ).
       " Part 1:
       " safe if both of the following are true:
       "     - The levels are either all increasing or all decreasing.
       "     - Any two adjacent levels differ by at least one and at most three.

       "
       " 1 loop over the input
       " 1.1 check if predecessor smaller or greater, remember the relation
       " 1.2 check if distance in the bounds 1 <= dist <= 3
       " 1.3 count if 1.1 till 1.3 given

       data count type i value 0.
       field-symbols: <level> type i,
                      <last_level> type i.
       data direction type c value space.
       data count_this_line type abap_bool value abap_true.
       loop at lines assigning field-symbol(<line>).
            data(levels) = split_into_levels( <line> ).
            unassign <last_level>.
            count_this_line = abap_true.
            direction = space.
            loop at levels assigning <level>. " no more expreiments!!
                if <last_level> is assigned.
                    if <last_level> gt <level> and ( direction eq space or direction eq 'D' ).
                        direction = 'D'.
                    elseif <last_level> lt <level> and (  direction eq space or direction eq 'A' ).
                        direction = 'A'.
                    else.
                        " equals are not counted
                        " criteria are not matched
                        count_this_line = abap_false.
                        exit.
                    endif.
                    if not abs(  <last_level> - <level> ) between 1 and 3.
                        count_this_line = abap_false.
                        exit.
                    endif.
                endif.
                assign <level> to <last_level>.
            endloop.
            if count_this_line eq abap_true.
                add 1 to count.
            endif.
       endloop.

        data(res_part1) = | Part 1: { count } |.
        res = res_part1.
    endmethod.

    method split_into_levels.
        find all occurrences of regex `(\d+)`
            in report
            results data(matches).
        levels =  value tt_level( for match in matches ( conv i( report+match-offset(match-length) ) ) ).
        " TODO try to understand the for generator syntax better , and what are the let expressions...?
    endmethod.


    method zif_aoc2024~resolve.
        data(res_part1) = part1(  puzzleinput ).
        data(res_part2) = part2(  puzzleinput ).
        result = | { res_part1 }; { res_part2 } |.
    endmethod.
ENDCLASS.