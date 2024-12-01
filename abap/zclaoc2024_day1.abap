class zclaoc2024_day1 definition
  public
  final
  inheriting from zclaoc2024_base
  create public .

  public section.
    methods:
        zif_aoc2024~resolve redefinition.
  protected section.
  private section.
*    methods: from base class
*      split_into_lines importing s type string returning value(lines) type tt_string.
endclass.



class zclaoc2024_day1 implementation.


  method zif_aoc2024~resolve.
    data(lines) = split_into_lines( puzzleinput  ).
    if lines( lines ) eq 0.
        result = `nothing to do, empy input`.
    else.
        " 1. split each row into thwo numbers and store into sorted tables
        data col1_tab type sorted table of i with non-unique key table_line.
        data col2_tab type sorted table of i with non-unique key table_line.
        data icol1 type i.
        data icol2 type i.
        loop at lines assigning field-symbol(<line>).
            find regex `(\d+)\s+(\d+)`
                in <line>
                submatches data(col1) data(col2).
            if sy-subrc ne 0.
                raise exception type cx_fatal_exception.
            endif.
            icol1 = col1. " manully cast by assigning values
            icol2 = col2.
            insert icol1 into table col1_tab.
            insert icol2 into table col2_tab.
        endloop.
        " 2. sort each table
        " --> tables are already sorted by definition
        " 3. itereate from lowest to highest calculating differences and summing up
        data(total_dist) = 0.
        loop at col1_tab assigning field-symbol(<c1>).
            data(c2) =  col2_tab[ sy-tabix ].
            data(dist) = abs( c2 - <c1> ).
            add dist to total_dist.
        endloop.

        " part 2:
        " adding up each number in the left list after multiplying it by
        " the number of times that number appears in the right list.
        data(sim_total) = 0.
        loop at col1_tab assigning <c1>.
            col1 = <c1>.
            data(nmatches) = 0.
            read table col2_tab with table key table_line = <c1> binary search transporting no fields.
            if sy-subrc eq 0.
                data(idx) = sy-tabix.
                while col2_tab[ idx ] eq <c1> .
                    add 1 to nmatches.
                    add 1 to idx.
                endwhile.
            endif.
            data(sim_single_value) = <c1> * nmatches.
            sim_total = sim_total  + sim_single_value.
        endloop.


        result = |part1: { total_dist }; part 2: { sim_total }|.
    endif.
  endmethod.
endclass.