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
          tt_three_groups type hashed table of t_three_group_repr with unique key table_line.
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
        find_groups.
endclass.



class zclaoc2024_day23 implementation.
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
    method find_groups.
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
        find_groups(  ).

        data(three_groups_dump) = dump_three_groups(  ).

        " filter has not the appropriate functional variant...
        " reducing..
        data(result_part1) = reduce i( init cnt_t = 0 for wa in three_groups
                                        next cnt_t =  cond i( when contains( val = wa regex = `t\w{5}|\w{2}t\w{3}|\w{4}t\w` )  then cnt_t + 1 else cnt_t )
                                     ).


        " part 2 seems like finding all longest pathes throug this graph, basically bfs
        " bye bye for now, see you in part 2 maybe today night, now i'm running out of time
        " stay healthy and keep coding.

        result = |Part 1: { result_part1 } \n{ three_groups_dump }\n { graph_dump } |.
    endmethod.
endclass.