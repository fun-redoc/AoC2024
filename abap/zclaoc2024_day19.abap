class zclaoc2024_day19 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        t_bigint type p length 16 decimals 0,
        begin of t_head_tail,
            head type string,
            tail type string,
        end of t_head_tail,
        begin of t_memo,
            key type string,
            cnt type t_bigint,
            end of t_memo,
        tt_memo type hashed table of t_memo with unique key key.
    data:
        memo type tt_memo,
        patterns type standard table of string with empty key,
        towel_designs  type standard table of string with empty key,
        queue type sorted table of t_head_tail with unique key table_line.
    methods:
        enq importing head type string tail type string,
        deq changing cur type t_head_tail returning value(res) type abap_bool,
        starts_with_pattern importing design type string pattern type string returning value(res) type abap_bool,
        without_head importing design type string head type string returning value(tail) type string,
        design_possible importing design type string returning value(res) type abap_bool,
        solve_part1 returning value(cnt_designs_possible) type i,
        find_patterns importing design type string
                      returning value(cnt) type t_bigint,
        read_puzzle importing puzzleinput type string.
endclass.



class zclaoc2024_day19 implementation.
    method find_patterns.
        data cnt_adj type t_bigint.
        data cnt_pat type t_bigint.
        " I'm trying the recursive version...
        if strlen( design ) eq 0.
            " we have walked down the whole design way along with the patterns
            cnt =  conv t_bigint( 1 ).
            exit.
        endif.

        " I'm going to create the frame method first, then I'm going to insert the memoization
        " memo
        read table memo with key key = design into data(memo_total).
        if sy-subrc eq 0.
            cnt = memo_total-cnt.
            exit.
        endif.

        data total_count  type t_bigint  value 0.
        loop at patterns assigning field-symbol(<pattern>).
            cnt_pat = 0.
            if starts_with_pattern( design = design pattern = <pattern> ).
                data(tail_design) = substring( val = design off = strlen( <pattern> ) ).
                " memo
                read table memo with key key = tail_design into data(memo_pat).
                if sy-subrc eq 0.
                    cnt_pat = memo_pat-cnt.
                else.
                    if strlen( tail_design ) > 0.
                        loop at patterns assigning field-symbol(<adj>).
                            if starts_with_pattern(  design = tail_design pattern = <adj> ).
                                cnt_adj = conv t_bigint( 0 ).
                                read table memo with key key = tail_design into data(memo_adj).
                                if sy-subrc eq 0.
                                    cnt_adj = memo_adj-cnt.
                                else.
                                    data(adj_tail_design) = substring( val = tail_design off = strlen( <adj> ) ).
                                    cnt_adj = find_patterns( design = adj_tail_design ).
                                    insert value #( key = adj_tail_design cnt = cnt_adj ) into table memo.
                                endif.
                                cnt_pat = cnt_pat + cnt_adj.
                            endif.
                        endloop.
                    else.
                        cnt_pat = cnt_pat + conv t_bigint( 1 ).
                    endif.
                    insert value #( key = tail_design cnt = cnt_pat ) into table memo.
                endif.
                total_count = total_count + cnt_pat.
            endif.
        endloop.
        insert value #( key = design cnt = total_count ) into table memo.
        cnt = total_count.
    endmethod.


    method enq.
"        append value #( head = head tail = tail ) to queue.
        insert value #( head = head tail = tail ) into table queue.
    endmethod.
    method deq.
        res = abap_false.
        if lines(  queue ) > 0.
            cur = queue[ 1 ].
            delete queue index 1.
            res = abap_true.
        endif.
    endmethod.
    method starts_with_pattern.
        res = abap_false.
        try.
            data(head) = substring( val = design off = 0 len = strlen( pattern ) ).
            if head eq pattern.
                res = abap_true.
            endif.
        catch cx_sy_range_out_of_bounds.
            res = abap_false.
        endtry.
    endmethod.
    method without_head.
        tail = replace( val = design
                        off = 0 len = strlen( head )
                        with = `` ).
    endmethod.
    method design_possible .
        "general idea -- pseudo code --
        "while not start and cur = deq.
            " if cur-head == design
            "    ready

            " for all patterns
            "   if cur-rest starts with pattern
            "     enq( cur-head &&= pattern,cur-tail = design without cur-try && pattern)
        "endwhile.
        data cur type t_head_tail.
        res = abap_false.
        enq( head = `` tail = design ). " BEWARE: there can be duplicates within the queue, this is ok if only existence asked
        while deq(  changing cur = cur ) ne abap_false.
            if strlen( cur-tail ) eq 0 and design eq cur-head.
                res = abap_true.
                exit.
            endif.
            loop at patterns assigning field-symbol(<pattern>).
                if starts_with_pattern( design = cur-tail pattern = <pattern> ).
                    data(new_head) = cur-head && <pattern>.
                    data(new_tail) = without_head( design = cur-tail head = <pattern> ).
                    enq( head = new_head tail = new_tail ).
                endif.
            endloop.
        endwhile.
    endmethod.
    method solve_part1.
        clear cnt_designs_possible.
        loop at towel_designs assigning field-symbol(<design>).
            if design_possible( <design> ) eq abap_true.
                add 1 to cnt_designs_possible.
            endif.
        endloop.
    endmethod.
 method read_puzzle.
    data tmp_patterns type standard table of string with empty key.
    data(lines) = split_into_lines( puzzleinput ).
    loop at lines assigning field-symbol(<line>).
        if sy-tabix eq 1.
            " patterns line
            "white (w), blue (u), black (b), red (r), or green (g)
            find all occurrences of regex `([wubrg]+)` in <line> results data(matches).
            loop at matches assigning field-symbol(<match>).
                data(pattern) = <line>+<match>-offset(<match>-length) .
                append pattern to tmp_patterns.
            endloop.
        else.
            " towel designs
            append <line> to towel_designs.
        endif.
    endloop.
    loop at tmp_patterns assigning field-symbol(<pattern>).
        "if <pattern> eq `ruuggwr`.
        "    "break-point.
        "endif.
        "find first occurrence of regex <pattern> in table towel_designs match line  data(l).
        "if sy-subrc eq 0.
            append <pattern> to patterns.
        "endif.
    endloop.
 endmethod.
 method zif_aoc2024~resolve.
    " IDEA
    " 1 alt.: use kind of BFS or DFS
    " 2 alt.: use backtracking (which corresponds to DFS - mostly)
    " i opt for BFS after yesterdays success with BFS

    read_puzzle( puzzleinput ).

    data(result_part1) = solve_part1(  ).

    result = |Part 1: { result_part1 }\npatterns: { lines( patterns ) } towels { lines( towel_designs ) }|.

    " OK this is too slow, will recap in the evening
    " 1. faster queue ( no dubbletes)
    " 2. pruning the search space e.g... lets see

    "bye for now, and have nice day...
    " hello again....
    "
    " the algorithm from part 1 is definittelly to slow to solve part 2.
    " => rewrting it

    " 2 main ideas
    " 1. use the patterns as a graph (i thin adajcence matrix is appropriate for this) and the design as a way through the graph
    " 2. use bfs or dfs with memoizing ( becouse patterns will repeat, once used pattern / way taken through the graph) has not to be calculated again

    " Part 2

    data total_cnt_patterns type t_bigint value 0. " I think it is going to be really big
    loop at towel_designs assigning field-symbol(<design>).
        clear memo.
       data(cnt_patterns) = find_patterns( design = <design> ) .
       add cnt_patterns to total_cnt_patterns.
    endloop.

    result = |Part 1: { result_part1 }\nPart 2: { total_cnt_patterns }\npatterns: { lines( patterns ) } towels { lines( towel_designs ) }|.

 endmethod.
endclass.