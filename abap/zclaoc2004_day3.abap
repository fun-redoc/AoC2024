class zclaoc2024_day3 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
   types:
       " ABAP Structe definition...
       begin of t_product,
        m1 type i,
        m2 type i,
       end of t_product,
       " ABAP array (as 'internal' table)
       tt_product type standard table of t_product with empty key.
   methods:
    parse_part2 importing program type string changing muls_tab type tt_product,
    parse_line_for_mul_statements importing line type string
                                  changing muls_tab type tt_product.
endclass.



class zclaoc2024_day3 implementation.
    method parse_part2.
    " TIPP alwas acitvate before testing new version :-))))
        data do_it type abap_bool value abap_true.
        find all occurrences of regex `mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)`
            in program
            results data(matches).
        loop at matches assigning field-symbol(<match>).
            data(matched_token) = program+<match>-offset(<match>-length).
            cl_demo_output=>display( matched_token ).
            if matched_token eq `do()`.
                do_it = abap_true.
            elseif matched_token eq `don't()`.
                do_it = abap_false.
            else.
                if do_it eq abap_true.
                    " extract submatches
                    data(match1) = <match>-submatches[ 1 ].
                    data(match2) = <match>-submatches[ 2 ].
                    " pull from string
                    data(m1) = program+match1-offset(match1-length).
                    data(m2) = program+match2-offset(match2-length).
                    " put to muls array
                    append initial line to muls_tab assigning field-symbol(<new_mul_entry>).
                    <new_mul_entry>-m1 = m1.
                    <new_mul_entry>-m2 = m2.
                endif.
            endif.

        endloop.
    endmethod.

    method parse_line_for_mul_statements.
 " every regex interpreter is differen don't know if I have to unescape ,
        find all occurrences of regex `mul\((\d{1,3}),(\d{1,3})\)`
            in line
            results data(matches).
        loop at matches assigning field-symbol(<match>).
            " extract submatches
            data(match1) = <match>-submatches[ 1 ].
            data(match2) = <match>-submatches[ 2 ].
            " pull from string
            data(m1) = line+match1-offset(match1-length).
            data(m2) = line+match2-offset(match2-length).
            " put to muls array
            append initial line to muls_tab assigning field-symbol(<new_mul_entry>).
            <new_mul_entry>-m1 = m1.
            <new_mul_entry>-m2 = m2.
        endloop.
    endmethod.
    method zif_aoc2024~resolve.
        " TODO
        " 1. split into lines
        " 2. parse for mul(X,Y) expressions, extract X,Y
        "    -> thank god there are regular expressions
        " 3. do the maths (SUMi Xi*yi)
        data(lines) = split_into_lines( puzzleinput ).
        data muls_tab type tt_product.
        loop at lines assigning field-symbol(<line>).
            parse_line_for_mul_statements( exporting line = <line> changing muls_tab = muls_tab ).
        endloop.
        " hey, here i can try the new reduce statemen for doing the math...
        " reduce in 'normal' laguages works as follows:
        " result = reduce( (accumulator, value) => do_somethhing(accumultor, value), some_iterable_strucure, initial_value)
        " in this case:
        " result = reduce( (acc, v) => acc + v.m1*v.m2, muls_tab, 0 )
        " now in ABAP 7.52
        data(result_part1) = reduce i(
            init acc = 0
            for prod in muls_tab
            next acc = acc + prod-m1 * prod-m2
        ) .

        " hopefully the result fill not be bigger than 32 bit....
        data(res_part1) = | Part 1: { result_part1 }|. " after 38minutes

        " PART 2
        " on line again, welcome to the part 2 of day 3...happy coding!
        " IDEA:
        " again use regular expression to parse for mul(X,Y), do(), don't().
        " depending auf what was faound last gather muls or skip them....
        " doing math stays the same
        clear muls_tab.
*        loop at lines assigning <line>. " line was already declared above if you wonder.
*            parse_part2( exporting line = <line> changing muls_tab = muls_tab  ).
*        endloop.
         " trying something else, the regexp also know how to handle linebreaks, i think
         parse_part2( exporting program = puzzleinput changing muls_tab = muls_tab  ).


        data(result_part2) = reduce i(
            init acc = 0
            for prod in muls_tab
            next acc = acc + prod-m1 * prod-m2
        ) .
        data(res_part2) = | Part 2: { result_part2 }|. " after 38minutes


        result = | { res_part1 }; { res_part2 } |.
    endmethod.
endclass.