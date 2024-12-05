class zclaoc2024_day5 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods:
        zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_ordering_rule,
            pred type i,
            succ type i,
        end of t_ordering_rule,
        tt_ordering_rule type table of t_ordering_rule
                          with non-unique sorted key pred components pred succ,
        tt_page_update type standard table of i with empty key.
    methods:
        order_update importing ordering_rules type tt_ordering_rule
                     changing unordered_update type tt_page_update,
        check_order importing ordering_rules type tt_ordering_rule
                              page_update type tt_page_update
                    returning value(is_ordered) type abap_bool,
        parse_ordering_rule importing line type string
                            returning value(or) type t_ordering_rule
                            exceptions parse_error,
        parse_page_update importing line type string returning value(pu) type tt_page_update.
ENDCLASS.



CLASS ZCLAOC2024_DAY5 IMPLEMENTATION.


    method check_order.
        " idea
        "   ASSUMPTION: there are no transitive rules
        "   start from rear
        "   pick 2 pages (pred, succ)
        "   check if there is a rule pred|succ
        " if all pairs match a rule the update is ordered
        " !!! its basically bubble sort!
        "  if bubble sort works so shooul every sorting alg. which can take an arbitrary comparison function
        "    -> this is not so easy with abap.
        "       the syntax variant by (otab) would allow it, you would have to enroll the order tab ...
        data(idx) = lines( page_update ).
        is_ordered = abap_true.
        while idx gt 1 and is_ordered eq abap_true.
            data(succ) = page_update[ idx ].
            data(pred) = page_update[ idx - 1 ].

            read table ordering_rules
                with table key pred components pred = pred succ = succ
                transporting no fields.
            if sy-subrc ne 0.
                is_ordered = abap_false.
            endif.

            subtract 1 from idx.
        endwhile.
    endmethod.


    method order_update.
        " 2. walk from rear
        " 3. if one unordered place found, search for an appropriate replacement (
        "    (that's the hard part!)
        data(idx) = lines( unordered_update ).
        while idx gt 1.
            data(succ) = unordered_update[ idx ].
            data(pred) = unordered_update[ idx - 1 ].

            " maybe calling sort with a propper comparison function wuld be the solution?
            "
            read table ordering_rules
                with table key pred components pred = pred succ = succ
                transporting no fields.
            if sy-subrc ne 0.
                data(tmp) = unordered_update[ idx ].
                unordered_update[ idx ] = unordered_update[ idx - 1 ].
                unordered_update[ idx - 1 ] = tmp.
                idx = lines(  unordered_update ).
            else.
                subtract 1 from idx.
            endif.

        endwhile.
    endmethod.


    method parse_ordering_rule.
        find first occurrence of regex `(\d{2})\|(\d{2})`
            in line
            submatches data(pred) data(succ).
        if sy-subrc ne 0.
            raise parse_error.
        endif.
        or-pred = pred.
        or-succ = succ.
    endmethod.


    method parse_page_update.
        find all occurrences of regex `(\d{2})`
            in line
            results data(matches).
        if sy-subrc ne 0.
            raise exception type cx_fatal_exception.
        endif.
        " this is the ABAP map-statement
        pu = value tt_page_update( for match in matches ( conv i( line+match-offset(match-length) ) ) ).

    endmethod.


    method zif_aoc2024~resolve.
        " IDEA
        " 1. read until first empty line, and parse rules
        " 2. read until end, and parse page numbers for product updates
        " 3. check for each product_update it rules apply
        data(lines) = split_into_lines( puzzleinput ).
        data status type c length 2 value 'OR'.
        data ordering_rules type tt_ordering_rule.
        data page_updates type standard table of tt_page_update.
        loop at lines assigning field-symbol(<line>).
            if status eq 'OR'.
                "data(ordering_rule) = parse_ordering_rule( exporting line = <line>  exceptions  ).
                " OLD syntax, sometimes useful
                call method parse_ordering_rule exporting line = <line>
                                    receiving or = data(ordering_rule)
                                    exceptions parse_error = 4.
                if sy-subrc ne 0.
                    status = 'PU'.
                else.
                   append ordering_rule to ordering_rules.
                endif.
            endif.
            if status eq 'PU'.
                data(page_update) = parse_page_update(  <line> ).
                append page_update to page_updates.
            endif.
        endloop.

        " now process all page_updates
        " checking the order, remebering the indexes of all corret updates
        data ordered_updates_idx type table of i with empty key.
        data unordered_updates_idx type table of i with empty key.
        loop at page_updates assigning field-symbol(<upd>).
            data(idx) = sy-tabix.
            data(is_ordered) = check_order( ordering_rules = ordering_rules page_update = <upd> ).
            if is_ordered eq abap_true.
                append idx to ordered_updates_idx.
            else.
                append idx to unordered_updates_idx.
            endif.
        endloop.
        data result_part1 type i value 0.
        loop at ordered_updates_idx into idx.
            data(update) = page_updates[ idx ].
            data(update_len) = lines(  update ).
            if update_len mod 2 ne 0.
                data(update_middle_idx) = 1 + update_len div 2.
            else.
                " does this case exist??
                update_middle_idx = update_len div 2.
            endif.
            data(middle_elem) = update[ update_middle_idx ].
            add middle_elem to result_part1.
        endloop.

        " HELLO AGAIN,
        " and welcome to Part 2 of Advent of Code 2024 Day 5....

        " TODO
        " 1. take all pageupdate that are not in order
        " 2. walk from rear
        " 3. if one unordered place found, search for an appropriate replacement (
        "    (that's the hard part!)
        " btw. now i'm listening to the jazz&blues playlist from YT Mediatheke

        data result_part2 type i value 0.
        loop at unordered_updates_idx into idx.
            data(unordered_update) = page_updates[ idx ].
            data(ordered_update) = unordered_update.
            order_update( exporting ordering_rules = ordering_rules changing unordered_update = ordered_update ).
            update_len = lines(  ordered_update ).
            if update_len mod 2 ne 0.
                update_middle_idx = 1 + update_len div 2.
            else.
                " does this case exist??
                update_middle_idx = update_len div 2.
            endif.
            middle_elem = ordered_update[ update_middle_idx ].
            add middle_elem to result_part2.
        endloop.
        " 97,13,75,29,47
        " 97,13,75,47,29
        " 97,13,75,47,29
        " 97,75,13,47,29 <- from the beginning
        " 97,75,47,29,13 <- ftb
        "  maybe this works (reminds me of bubble sort)
        " then good luck!
        " finally!!

        result = | Part 1: { result_part1 }; Part 2: { result_part2 }|.
    endmethod.
ENDCLASS.