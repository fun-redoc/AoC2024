class zclaoc2024_day23 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
      types:
          t_node type char2,
          t_three_group_repr type char6,
          begin of t_adjacence,
            node type t_node,
            neighbours type hashed table of t_node with unique key table_line,
            end of t_adjacence,
          tt_graph type hashed table of t_adjacence with unique key node,
          begin of t_queue_node ,
            node type t_node,
            cnt type i,
            pred type ref to data,
          end of t_queue_node,
          t_three_group type sorted table of t_node with unique key table_line,
          tt_intercon_group type sorted table of t_node with unique key table_line,
          tt_three_groups type hashed table of t_three_group_repr with unique key table_line,
          begin of t_queue_intercon,
            grp type t_three_group_repr,
            linked type ref to data,
          end of t_queue_intercon.
      data:
          graph type tt_graph,
          three_groups type tt_three_groups.
      methods:
        dump_three_groups returning value(string_repr) type string,
        dump_graph returning value(string_repr) type string,
        register_three_group importing qnode type t_queue_node,
        check_is_loop importing qnode type t_queue_node
                        returning value(res) type abap_bool,
        insert_into_graph importing from_node type t_node
                                      to_node type t_node,
        read_puzzle importing puzzleinput type string,
        find_interconnected_groups returning value(max_intercon_group) type tt_intercon_group,
        check_have_two_common importing grp1 type t_three_group_repr
                                        grp2 type t_three_group_repr
                              changing common1 type t_node
                                       common2 type t_node
                                       other_of_grp2 type t_node
                             returning value(res) type abap_bool,
        check_has_connection_to_all importing grp type t_three_group_repr
                                              node type t_node
                                    returning value(res) type abap_bool,
        find_3_groups.
endclass.



class zclaoc2024_day23 implementation.
    method check_have_two_common.
        " assumption grp1 and grp2 have a sorted representation
        " checking cases  xx., x.x, .xx
        data g11 type t_node.
        data g12 type t_node.
        data g13 type t_node.
        data g21 type t_node.
        data g22 type t_node.
        data g23 type t_node.
        g11 = grp1+0(2). g12 = grp1+2(2). g13 = grp1+4(2).
        g21 = grp2+0(2). g22 = grp2+2(2). g23 = grp2+4(2).
        if g11 eq g21 and g12 eq g22.
            common1 = g11.
            common2 = g12.
            other_of_grp2 = g23.
            res = abap_true.
            exit.
        endif.
        if g11 eq g21 and g13 eq g23.
            common1 = g11.
            common2 = g13.
            other_of_grp2 = g22.
            res = abap_true.
            exit.
        endif.
        if g12 eq g22 and g13 eq g23.
            common1 = g12.
            common2 = g13.
            other_of_grp2 = g21.
            res = abap_true.
            exit.
        endif.
        res = abap_false.
    endmethod.

    method check_has_connection_to_all.
        data grp_nd type t_node.
        read table graph with key node = node assigning field-symbol(<adjacence>).
        if sy-subrc ne 0.
            raise exception type cx_fatal_exception.
        endif.
        res = abap_true.
        do 3 times.
            data(i) = sy-index - 1.
            data(off) = i * 2.
            grp_nd = grp+off(2).
            read table <adjacence>-neighbours with key table_line = grp_nd transporting no fields.
            if sy-subrc ne 0.
                res = abap_false.
                exit.
            endif.
        enddo.
    endmethod.

    method find_interconnected_groups.
        " IDEA
        " successivielly add 3-groups
        " two 3 groups can be joined iff they have 2 elements in common and the third is conneted to all other
        data queue type table of t_queue_intercon with empty key.
        data finished type hashed table of t_queue_intercon with unique key grp.
        data r_qintercon type ref to t_queue_intercon.
        field-symbols <qintercom> type t_queue_intercon.
        data: c1 type t_node, c2 type t_node, c3 type t_node, other type t_node.
        data intercon type tt_intercon_group.
        loop at three_groups assigning field-symbol(<grp>).
            clear queue.
            clear finished.
            append value #(  grp = <grp> ) to queue.

            while lines(  queue ) > 0.

                data(cur) = queue[ 1 ].
                delete queue index 1.

                insert cur into table finished.

                " now I need to find all 3-groups with 3 nodes in common with cur and a connection to the remaining one
                "  i'm going to loop, if it turns out too slow, i'll improve later
                loop at three_groups assigning field-symbol(<adj>).
                    read table finished with key grp = <adj> transporting no fields.
                    if sy-subrc ne 0.
                        if <adj> ne cur-grp.
                            if check_have_two_common( exporting grp1 = cur-grp grp2 = <adj> changing common1 = c1 common2 = c1 other_of_grp2 = other ).
                                if check_has_connection_to_all( grp = cur-grp node = other ).
                                    " can be worked on, belongs to the group
                                    create data r_qintercon.
                                    r_qintercon->* = cur.
                                    append value #( grp = <adj> linked = r_qintercon  ) to queue.
                                endif.
                            endif.
                       endif.
                    endif.
                endloop.

            endwhile.

            " unwind the linked list to node group
            clear intercon.
            data r type ref to data.
            r = ref #( cur ).
            while r is bound.
                assign r->* to <qintercom>.
                insert <qintercom>-grp+0(2) into table intercon.
                insert <qintercom>-grp+2(2) into table intercon.
                insert <qintercom>-grp+4(2) into table intercon.
                r = <qintercom>-linked .
            endwhile.
            if lines( intercon ) > lines( max_intercon_group ).
                max_intercon_group = intercon.
                " TODO can there be several with max_size, and if yes what to do?
            endif.

        endloop.
    endmethod.

    method check_is_loop.
        " loop is if top and bottom element of this linked list are same
        data(top) = qnode-node.
        data ptr type ref to data.
        field-symbols <ptr> type t_queue_node.
        ptr = ref #( qnode ).
        while ptr is bound.
            assign ptr->* to <ptr>.
            ptr = <ptr>-pred.
        endwhile.
        if <ptr>-node eq top.
            res = abap_true.
        else.
            res = abap_false.
        endif.
    endmethod.

    method register_three_group.
        if qnode-cnt ne 3.
            raise exception type cx_fatal_exception.
        endif.
        data three_tab type t_three_group.
        field-symbols: <qnode> type t_queue_node.
        data r_cur type ref to data.
        r_cur = ref #(  qnode ).
        data(cnt) = 0.
        " backloop and gather nodes for the three group
        " sorting is going to make the 3 group distinct
        while r_cur is bound.
            add 1 to cnt.
            assign r_cur->* to <qnode>.
            insert <qnode>-node into table three_tab.
            r_cur = <qnode>-pred.
        endwhile.
        if cnt ne 3.
            raise exception type cx_fatal_exception.
        endif.

        "serialize into string representation
        data new_three_group type t_three_group_repr.
        loop at three_tab assigning field-symbol(<nd>).
            new_three_group = new_three_group && <nd>.
        endloop.

        insert new_three_group into table three_groups.

    endmethod.
    method dump_three_groups.
        string_repr = ||.
        loop at three_groups assigning field-symbol(<g>).
            string_repr = |{ string_repr }\n{ <g>+0(2) },{ <g>+2(2) },{ <g>+4(2) }|.
        endloop.
    endmethod.
    method dump_graph.
        string_repr = ||.
        loop at graph assigning field-symbol(<from>).
            string_repr = |{ string_repr }\n{ <from>-node }->[|.
            loop at <from>-neighbours assigning field-symbol(<to>).
                string_repr = |{ string_repr }{ <to> },|.
            endloop.
            string_repr = substring( val = string_repr off = 0 len = strlen( string_repr ) - 1 ). " get rid of trailing ','
            string_repr = |{ string_repr }]\n|.
        endloop.
    endmethod..
    method insert_into_graph.
            read table graph with table key node = from_node assigning field-symbol(<adjacence>).
            if sy-subrc ne 0.
                " still not in graph
                insert value t_adjacence( node = from_node ) into table graph assigning field-symbol(<node>).
                insert to_node into table <node>-neighbours.
            else.
                " already in graph
                insert to_node into table <adjacence>-neighbours.
            endif.
    endmethod.
    method read_puzzle.
        data(lines) = split_into_lines(  puzzleinput ).
        loop at lines assigning field-symbol(<line>).

            find first occurrence of regex `(\w{2})-(\w{2})` in <line>
                submatches data(nd1) data(nd2).
            if sy-subrc ne 0.
                raise exception type cx_fatal_exception.
            endif.

            " add to adjeceny matrix
            data node1 type t_node.
            data node2 type t_node.
            node1 = conv t_node( nd1 ).
            node2 = conv t_node( nd2 ).
            insert_into_graph( from_node = node1 to_node = node2 ).
            insert_into_graph( from_node = node2 to_node = node1 ).
        endloop.
    endmethod.
    method find_3_groups.
        " its may be like traversing a graph, and registering loops..
        " alternativels loop over all nodes and check for 3-group
        " i'm going to try the loop idea -> bfs
        data pred type ref to t_queue_node.
        data queue type standard table of t_queue_node with empty key.
        data visited type hashed table of t_queue_node with unique key node.
        loop at graph assigning field-symbol(<start_node>).
            clear queue.
            clear visited.
            append value #( node = <start_node>-node cnt = 1 ) to queue.
            while lines(  queue ) > 0.
                data(cur) = queue[ 1 ].
                delete queue index 1.
                if cur-cnt eq 4.
                    if check_is_loop( cur ).
                        field-symbols <pred> type t_queue_node.
                        assign cur-pred->* to <pred>.
                        register_three_group( <pred> ).
                    endif.
                    continue.
                endif.

                insert cur into table visited.

                read table graph with key node = cur-node into data(cur_node).
                loop at cur_node-neighbours into data(next).
                   create data pred.
                   pred->* = cur.
                   data(next_node) = value t_queue_node( node = next cnt = cur-cnt + 1 pred = pred ).
                   read table visited with key node = next_node-node into data(next_node_already_visited).
                   if sy-subrc eq 0.
                    if next_node_already_visited-cnt eq 4.
                        "TODO add to the 3 groups
                        if check_is_loop( cur ).
                            assign cur-pred->* to <pred>.
                            register_three_group( <pred> ).
                            register_three_group( next_node_already_visited ).
                        endif.
                    else.
                        if next_node_already_visited-cnt lt 4.
                            insert next_node into table queue.
                        endif.
                    endif.
                   else.
                    " search on
                    insert next_node into table queue.
                   endif.
                endloop.
            endwhile.
        endloop.

    endmethod.
    method zif_aoc2024~resolve.

        " IDEA
        " 1. read interconnections
        " 2. build an adjacence matrix
        " 3. check all tripplets .... oh.. this could bee too slow. but lets try, maybe I come up with a better idea while coding

        read_puzzle( puzzleinput ).
        data(graph_dump) = dump_graph(  ). "<<- not needed but for fun
        find_3_groups(  ).

        data(three_groups_dump) = dump_three_groups(  ).

        " filter has not the appropriate functional variant...
        " reducing..
        data(result_part1) = reduce i( init cnt_t = 0 for wa in three_groups
                                        next cnt_t =  cond i( when contains( val = wa regex = `t\w{5}|\w{2}t\w{3}|\w{4}t\w` )  then cnt_t + 1 else cnt_t )
                                     ).

        " Part 2
        data(max_intercon_group) = find_interconnected_groups(  ).
        data(result_part2) = reduce string( init s = `` for g in max_intercon_group next s = s && g && `,` ).
        result_part2 = substring( val = result_part2 off = 0 len = strlen( result_part2 ) - 1 ).
        
        " since the computation takes more than the web timeout and I have no immidiate idea
        " how wo accelerate, i've sent the progam top background processing
        " will come in an hour or so to look after it....
        " bye bye until then ...
        " have a wonderful christmas time and keep coding.
        
        

        result = |Part 1: { result_part1 } Part 2: { result_part2 } \n{ three_groups_dump }\n { graph_dump } |.
    endmethod.
endclass.