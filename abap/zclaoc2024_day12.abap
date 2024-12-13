class zclaoc2024_day12 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_patch,
            kind type char1,
            cnt_others type i, "count neighbours different kind
            cnt_same   type i, "count of neighbours same kind
            cnt_bounds type i, "count adjacent boudaries
            region_idx type i, " index of the region I belong to
        end of t_patch,
        tt_areal type table of zclaoc2024_matrix=>t_v2 with empty key,
        begin of t_region,
            kind type char1,
            perimeter type i,
            area type i,
            sides type i,
            areal type tt_areal,
        end of t_region,
        tt_regions type standard table of t_region with empty key,
        tt_trace type hashed table of zclaoc2024_matrix=>t_v2 with unique key x y.
    data:
        map type ref to zclaoc2024_matrix.
    methods:
        up importing pos type zclaoc2024_matrix=>t_v2 returning value(res) type zclaoc2024_matrix=>t_v2,
        down importing pos type zclaoc2024_matrix=>t_v2 returning value(res) type zclaoc2024_matrix=>t_v2,
        left importing pos type zclaoc2024_matrix=>t_v2 returning value(res) type zclaoc2024_matrix=>t_v2,
        right importing pos type zclaoc2024_matrix=>t_v2 returning value(res) type zclaoc2024_matrix=>t_v2,
        above_kind importing pos type zclaoc2024_matrix=>t_v2 returning value(kind) type t_region-kind,
        below_kind importing pos type  zclaoc2024_matrix=>t_v2 returning value(kind) type t_region-kind,
        left_kind importing pos type  zclaoc2024_matrix=>t_v2 returning value(kind) type t_region-kind,
        right_kind importing pos type  zclaoc2024_matrix=>t_v2 returning value(kind) type t_region-kind,
        ahead importing pos type zclaoc2024_matrix=>t_v2
                        dir type zclaoc2024_matrix=>t_v2
              returning value(res) type zclaoc2024_matrix=>t_v2,
        turn importing dir type zclaoc2024_matrix=>t_v2
              returning value(res) type zclaoc2024_matrix=>t_v2,
        count_neighbours,
        count_neighbours_by_v2 importing adjacent type zclaoc2024_matrix=>t_v2
                                changing patch type t_patch ,
        calc_area_and_perimeter importing region_idx type i changing region type t_region,
        walk_the_areal importing kind type char1
                                 pos type zclaoc2024_matrix=>t_v2
                                 dir type zclaoc2024_matrix=>t_v2
                       changing  trace type tt_trace
                                 acc_areal type tt_areal
                       returning value(ok) type abap_bool,  "area accumulator
        determin_regions returning value(regions) type tt_regions,
        determin_v_sides changing regions type tt_regions,
        determin_h_sides changing regions type tt_regions,
        determin_the_sides changing regions type tt_regions,
        read_map importing puzzleinput type string.
endclass.



class zclaoc2024_day12 implementation.
    method above_kind.
       field-symbols: <patch> type t_patch.
       clear kind.
       data(above_pos) = up( pos ).
       if map->check_in_bounds( above_pos ) eq abap_true.
            data(patch_r) = map->get_by_v2( above_pos ).
            assign patch_r->* to <patch>.
           kind = <patch>-kind.
       endif.
    endmethod.
    method below_kind.
       field-symbols: <patch> type t_patch.
       clear kind.
       data(below_pos) = down( pos ).
       if map->check_in_bounds( below_pos ) eq abap_true.
            data(patch_r) = map->get_by_v2( below_pos ).
            assign patch_r->* to <patch>.
           kind = <patch>-kind.
       endif.
    endmethod.
    method left_kind.
       field-symbols: <patch> type t_patch.
       clear kind.
       data(left_pos) = left( pos ).
       if map->check_in_bounds( left_pos ) eq abap_true.
            data(patch_r) = map->get_by_v2( left_pos ).
            assign patch_r->* to <patch>.
           kind = <patch>-kind.
       endif.
    endmethod.
    method right_kind.
       field-symbols: <patch> type t_patch.
       clear kind.
       data(right_pos) = right( pos ).  " TODO get rid of those copy paste , to do that redesign up/down/left/right...methods
       if map->check_in_bounds( right_pos ) eq abap_true.
            data(patch_r) = map->get_by_v2( right_pos ).
            assign patch_r->* to <patch>.
           kind = <patch>-kind.
       endif.
    endmethod.
    method determin_v_sides.
        field-symbols: <patch> type t_patch.
        data prev_kind type t_patch-kind.
        data prev_above type t_patch-kind.
        data prev_below type t_patch-kind.
        do map->rows times.
            data(y) = sy-index.
            clear prev_kind.
            clear prev_above.
            clear prev_below.
            do map->cols times.
                data(x) = sy-index.
                "
                data(pos) = value zclaoc2024_matrix=>t_v2( x = x y = y ).
                data(patch_r) = map->get_by_v2(  pos ).
                assign patch_r->* to <patch>.
                data(cur_kind) = <patch>-kind.
                data(above_kind) = above_kind( pos ).
                data(below_kind) = below_kind( pos ).

                if cur_kind ne prev_kind.
                    " the plant changes => a new side starts.
                    data(region_idx) = <patch>-region_idx. " yes!
                    data(region_r) = ref #( regions[ region_idx ] ).
                    " a side beginns only if above or below different kinds of plants are...

                    if above_kind ne cur_kind.
                        " one side above starts
                        add 1 to region_r->*-sides.
                    endif.
                    if below_kind ne cur_kind.
                        " one side below starts
                        add 1 to region_r->*-sides.
                    endif.
                else. " case C at (4,3)
                    if prev_above eq cur_kind and above_kind ne cur_kind. " not so clear...
                        add 1 to region_r->*-sides.
                    endif.
                    if prev_below eq cur_kind and below_kind ne cur_kind. " not so clear...
                        add 1 to region_r->*-sides.
                    endif.
                endif.

                prev_kind = cur_kind.
                prev_above = above_kind.
                prev_below = below_kind.
                "
            enddo.
        enddo.
    endmethod.
    method determin_h_sides.
        field-symbols: <patch> type t_patch.
        data prev_kind type t_patch-kind.
        data prev_left type t_patch-kind.
        data prev_right type t_patch-kind.
        do map->cols times. " flip cols/rows to traverse horizontally.. TODO refactor copy paste
            data(x) = sy-index.
            clear prev_kind.
            clear prev_left.
            clear prev_right.
            do map->rows times.
                data(y) = sy-index.
                "
                data(pos) = value zclaoc2024_matrix=>t_v2( x = x y = y ).
                data(patch_r) = map->get_by_v2(  pos ).
                assign patch_r->* to <patch>.
                data(cur_kind) = <patch>-kind.
                data(left_kind) = left_kind( pos ).
                data(right_kind) = right_kind( pos ).

                if cur_kind ne prev_kind.
                    " the plant changes => a new side starts.
                    data(region_idx) = <patch>-region_idx. " yes!
                    data(region_r) = ref #( regions[ region_idx ] ).
                    " a side beginns only if left or right different kinds of plants are...

                    if left_kind ne cur_kind.
                        " one side left starts
                        add 1 to region_r->*-sides.
                    endif.
                    if right_kind ne cur_kind.
                        " one side right starts
                        add 1 to region_r->*-sides.
                    endif.
                else. " case C at (4,3)
                    if prev_left eq cur_kind and left_kind ne cur_kind. " not so clear...
                        add 1 to region_r->*-sides.
                    endif.
                    if prev_right eq cur_kind and right_kind ne cur_kind. " not so clear...
                        add 1 to region_r->*-sides.
                    endif.
                endif.

                prev_kind = cur_kind.
                prev_left = left_kind.
                prev_right = right_kind.
                "
            enddo.
        enddo.
    endmethod.
    method determin_the_sides.
        determin_v_sides( changing regions = regions ).
        determin_h_sides( changing regions = regions ).
    endmethod.
    method ahead.
        res = value #( x = pos-x + dir-x y = pos-y + dir-y ).
    endmethod.
    method turn. " turn to the right
        res = value #(  x = dir-y y = ( - dir-x ) ).
    endmethod.
    method walk_the_areal.
    " recursion end tests
        field-symbols: <patch> type t_patch.
        if map->check_in_bounds( pos ) eq abap_false.
            ok = abap_false.
            exit.
        endif.
        data(patch_r) = map->get_by_v2( pos ).
        assign patch_r->* to <patch>.
        if <patch>-kind ne kind.
            ok = abap_false.
            exit.
        endif.
        read table trace with key x = pos-x y = pos-y transporting no fields.
        if sy-subrc eq 0. " already visited
            ok = abap_false.
            exit.
        endif.

        " has the right kind, is not out of bounds and is not yet visited
        append pos to acc_areal.
        insert pos into table trace.
        if abap_false eq walk_the_areal( exporting kind = kind pos = ahead( pos = pos dir = dir ) dir = dir  changing trace = trace acc_areal = acc_areal ).
            data(new_dir) = turn( dir ).
            if abap_false eq walk_the_areal( exporting kind = kind pos = ahead( pos = pos dir = new_dir ) dir = new_dir  changing trace = trace acc_areal = acc_areal ).
                new_dir = turn( new_dir ).
                if abap_false eq walk_the_areal( exporting kind = kind pos = ahead( pos = pos dir = new_dir ) dir = new_dir  changing trace = trace acc_areal = acc_areal ).
                    if abap_false eq walk_the_areal( exporting kind = kind pos = ahead( pos = pos dir = new_dir ) dir = new_dir  changing trace = trace acc_areal = acc_areal ).
                        new_dir = turn( new_dir ).
                        if abap_false eq walk_the_areal( exporting kind = kind pos = ahead( pos = pos dir = new_dir ) dir = new_dir  changing trace = trace acc_areal = acc_areal ).
                            ok = abap_false. " all direactions checke no way to go
                            exit.
                        endif.
                    endif.
                endif.
            endif.
        endif.

        ok = abap_true.



    endmethod.
    method calc_area_and_perimeter.
        field-symbols: <patch> type t_patch.
        region-area = 0.
        region-perimeter = 0.
       loop at region-areal assigning field-symbol(<pos>).
        data(patch_r) = map->get_by_v2( <pos> ).
        assign patch_r->* to <patch>.
        assert region-kind eq <patch>-kind.
        add 1 to region-area .
        add <patch>-cnt_bounds to region-perimeter .
        add <patch>-cnt_others to region-perimeter .
        <patch>-region_idx = region_idx.
       endloop.
    endmethod.
    method determin_regions.
        field-symbols: <patch> type t_patch.
        data trace type  tt_trace.
        do map->rows times.
            data(y) = sy-index.
            do map->cols times.
                data(x) = sy-index.
                "
                read table trace with key x = x y = y transporting no fields.
                if sy-subrc ne 0. " not visited yet
                    data(pos) = value zclaoc2024_matrix=>t_v2( x = x y = y ).
                    data(patch_r) = map->get_by_v2( pos ).
                    assign patch_r->* to <patch>.
                    data(kind) = <patch>-kind.

                    " walk the areal
                    data areal type tt_areal.
                    clear areal.
                    walk_the_areal( exporting kind = kind  pos = pos dir = value #( x = 1 y = 0 )
                                    changing trace = trace acc_areal = areal ).
                    append value t_region( kind = kind areal = areal ) to regions assigning field-symbol(<region>).
                    calc_area_and_perimeter( exporting region_idx = lines( regions ) changing region = <region> ).

                endif.
                "
            enddo.
        enddo.

    endmethod.
    method count_neighbours_by_v2.
        field-symbols: <adjacent> type t_patch.

        if not map->check_in_bounds( adjacent ).
            add 1 to patch-cnt_bounds.
        else.
            data(adj_ref) = map->get_by_v2( adjacent ).
            assign adj_ref->* to <adjacent>. " oh this old syntax..
            if <adjacent>-kind eq patch-kind.
                add 1 to patch-cnt_same.
            else.
                add 1 to patch-cnt_others.
            endif.
        endif.
    endmethod.
    method count_neighbours.
        field-symbols: <patch> type t_patch.
        do map->rows times.
            data(y) = sy-index.
            do map->cols times.
                data(x) = sy-index.
                data(pos)  = value zclaoc2024_matrix=>t_v2( x = x y = y ).

                data(patch_ref) = map->get_by_v2( pos ).
                assign patch_ref->* to <patch>. " oh this old syntax..

                <patch>-cnt_bounds = 0.
                <patch>-cnt_others = 0.
                <patch>-cnt_same = 0.

                count_neighbours_by_v2( exporting adjacent =  up( pos ) changing patch = <patch> ).
                count_neighbours_by_v2( exporting adjacent =  down( pos ) changing patch = <patch> ).
                count_neighbours_by_v2( exporting adjacent =  left( pos ) changing patch = <patch> ).
                count_neighbours_by_v2( exporting adjacent =  right( pos ) changing patch = <patch> ).
            enddo.
        enddo.
    endmethod.
    method up.
        res = value zclaoc2024_matrix=>t_v2( x = pos-x y = pos-y - 1 ).
    endmethod.
    method down.
        res = value zclaoc2024_matrix=>t_v2( x = pos-x y = pos-y + 1 ).
    endmethod.
    method left.
        res = value zclaoc2024_matrix=>t_v2( x = pos-x - 1 y = pos-y ).
    endmethod.
    method right.
        res = value zclaoc2024_matrix=>t_v2( x = pos-x + 1 y = pos-y ).
    endmethod.
    method read_map.
        " I'm going to extend the matrix to be more general first.
        "   good luck in ABAP where there are no generics or templets
        data patch_ref type ref to t_patch.
        field-symbols: <patch> type t_patch.
        data(lines) = split_into_lines( puzzleinput ).
        data(rows) = lines(  lines ).
        data(cols) = strlen(  lines[ 1 ] ).
        map = new #( rows = rows cols = cols ).
        loop at lines assigning field-symbol(<line>).
            data(row) = sy-tabix.
            find all occurrences of regex `[A-Z]`
                in <line>
                results data(matches).
            loop at matches assigning field-symbol(<m>).
                data(col) = <m>-offset + 1.
                data(patch_kind) = <line>+<m>-offset(1).
                patch_ref = new t_patch( kind = patch_kind cnt_others = -1 cnt_same = -1 cnt_bounds = -1 ).
                map->put( y = row x = col v = patch_ref ).
            endloop.
        endloop.
    endmethod.
    method zif_aoc2024~resolve.
        " idea for Part 1:
        " - read into the Matrix implemented the Day 4.
        " - remember for each Element how many neighbour
        "   patchs of same type and of other type each patch has
        "   --> summing the numbers of others and out of bounds should give the perimeter
        " - count area traversing with a backtracking alg: "go ahead and count, turn right on obstacle or on already traversed , when turned 4 times end "
        read_map( puzzleinput ).

        count_neighbours(  ).

        data(regions) = determin_regions( ). " regions are plots of same kind beeing adjacent.

        data(cost_part1) = reduce i( init acc = 0 for r in regions next  acc = acc + r-perimeter * r-area  ).

        " Welcome to Part 2 of Day 12, this task is tricky..
        " i can imagin two approaches
        " 1. start with any point, move towords the bound of the region,
        "    walk the bound (fence) along, every change of direction means a new side...
        "    => similarly to the method walk_the_area
        " 2. traverse row wise then col wise.
        "    every change above or below ( left or right) resp. means the beginning of a new side
        "
        " I think I'm going for 2, seems easier to me, still--

        determin_the_sides( changing regions = regions ) .
        data(cost_part2) = reduce i( init acc = 0 for r in regions next  acc = acc + r-sides * r-area  ).


        result = | Part 1: { cost_part1 } Part 2: { cost_part2 }|.

    endmethod.
endclass.