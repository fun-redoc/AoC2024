class zclaoc2024_day24 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        t_bit type x length 1,
        t_64bit type x length 8,
        begin of t_wire,
            name type char3,
            value type i,
        end of t_wire,
        tt_wires type standard table of t_wire with key name,
        begin of t_gate,
            in1 type char3,
            r_in1 type ref to data, " binary tree by pointers
            in2 type char3,
            r_in2 type ref to data, " binary tree by pointers
            op type char2,
            out type char3, " <- seams to be unique ( at leas in z )
            allready_evaluated type abap_bool,
            eval_res type t_bit,
        end of t_gate,
        tt_gates type hashed table of t_gate with unique key out.
    data:
        wires type tt_wires,
        gates type tt_gates,
        zs type tt_gates.
    methods:
        bits importing v type t_64bit returning value(s) type string,
        eval importing in1 type t_bit in2 type t_bit op type char2 returning value(res) type t_bit,
        compute importing x type t_64bit y type t_64bit r_gate type ref to t_gate,
        compute_with_gates importing x type t_64bit y type t_64bit returning value(res) type t_64bit,
        make_graph,
        wires_val importing wire_prefix type char1 returning value(val) type t_64bit,
        read_puzzle importing puzzleinput type string.
endclass.



class zclaoc2024_day24 implementation.

    method bits.
        clear s.
        do 64 times.
            get bit sy-index of v into data(b).
            s = |{ s }{ b }|.
        enddo.
    endmethod.

    method wires_val.
        clear val.
        data(pattern) = wire_prefix && '++'.
        loop at wires assigning field-symbol(<wire>) where name cp pattern.
            data(pos) = conv i( substring( val = <wire>-name off = 1 len = 2 ) ).
            data(bit_pos) = 64 - pos.
            if <wire>-value ne 0.
                set bit bit_pos of val.
            endif.
        endloop.
    endmethod.

    method compute_with_gates.
        loop at gates assigning field-symbol(<g>).
            <g>-allready_evaluated = abap_false.
            clear <g>-eval_res.
        endloop.
        loop at zs assigning <g>.
            <g>-allready_evaluated = abap_false.
            clear <g>-eval_res.
        endloop.
        clear res.
        loop at zs reference into data(r_z).

            compute( x = x y = y r_gate =  r_z ).

            data(zpos) = conv i( substring( val = r_z->out off = 1 len = 2 ) ). " 0 - 45
            " set bit: 1 = most significant bit..., i have 64 bits thus bit pos is 64 - zpos
            data(bit_pos) = 64 - zpos.
            if r_z->eval_res ne 0. " the conversion errors...maybe overcome this way
                set bit bit_pos of res.
            endif.
        endloop.
    endmethod.

    method eval.
        case op.
            when 'AN'. res = in1 bit-and in2.
            when 'OR'. res = in1 bit-or in2.
            when 'XO'. res = in1 bit-xor in2.
            when others. raise exception type cx_fatal_exception.
        endcase.
    endmethod.

    method compute.
        field-symbols <gate> type t_gate.
        data in1 type t_bit.
        data in2 type t_bit.
        if r_gate is bound.
            if r_gate->allready_evaluated ne abap_true.

                if r_gate->r_in1 is bound.
                    " recurivelly descnding compoute the in1 value
                    assign r_gate->* to <gate>.
                    assign <gate>-r_in1->* to <gate>.
                    compute( x = x y = y r_gate = ref #( <gate> ) ). " abap has void* pointers
                    in1 = <gate>-eval_res.
                else.
                    " value comes from wire
                    data(in1prefix) = substring( val = r_gate->in1 off = 0 len = 1 ).
                    if not  ( in1prefix eq 'x' or in1prefix eq 'y' ).
                        raise exception type cx_fatal_exception.
                    endif.
                    data(v) = cond t_64bit( when in1prefix = 'x' then x else y ).
                    data(pos) = 64 - conv i( substring( val = r_gate->in1 off = 1 len = 2 ) ).
                    get bit pos of v into in1.
                endif.

                if r_gate->r_in2 is bound.
                    " recurivelly descnding compoute the in2 value
                    assign r_gate->* to <gate>.
                    assign <gate>-r_in2->* to <gate>.
                    compute( x = x y = y r_gate = ref #( <gate> ) ). " abap has void* pointers
                    in2 = <gate>-eval_res.
                else.
                    " value comes from wire
                    data(in2prefix) = substring( val = r_gate->in2 off = 0 len = 1 ).
                    if not  ( in2prefix eq 'x' or in2prefix eq 'y' ).
                        raise exception type cx_fatal_exception.
                    endif.
                    v = cond t_64bit( when in2prefix = 'x' then x else y ).
                    pos = 64 - conv i( substring( val = r_gate->in2 off = 1 len = 2 ) ).
                    get bit pos of v into in2.
                endif.

                " evaluateion of this gate
                r_gate->eval_res = eval( in1 = in1 in2 = in2 op = r_gate->op ).
                r_gate->allready_evaluated = abap_true.

            endif.
        endif.
    endmethod.

    method make_graph.
        " I#m going too trya to evaluate the expresseion from output to input
        " structuring them into a tree (better a forest where some trees will be stuck together)
        " out -> in1 -> in1   <- the leaves will be provided from wires
        "            -> in2
        "     -> in2 -> in1
        "            -> in2
        " the tree can be partly evaluated, which can be stored in the tree to prevent re evaluations
        loop at gates assigning field-symbol(<gate>).
            read table gates with key out = <gate>-in1 reference into <gate>-r_in1.
            read table gates with key out = <gate>-in2 reference into <gate>-r_in2.
            <gate>-allready_evaluated = abap_false.
            clear <gate>-eval_res.

            " need to remember z - roots (for results)
            if substring( val = <gate>-out off = 0 len = 1 ) eq `z`.
               insert <gate> into table zs.
            endif.
        endloop.

    endmethod.
    method read_puzzle.
"y02: 0
        find all occurrences of regex `([xy]\d\d):\s([01])` in puzzleinput results data(wire_matches).
        loop at wire_matches assigning field-symbol(<m>).
            data(wire_name_match) = <m>-submatches[ 1 ].
            data(wire_name) = puzzleinput+wire_name_match-offset(wire_name_match-length).
            data(wire_value_match) = <m>-submatches[ 2 ].
            data(wire_value) = puzzleinput+wire_value_match-offset(wire_value_match-length).
            insert value #( name = wire_name value = wire_value ) into table wires.
        endloop.

"x00 AND y00 -> z00
        find all occurrences of regex `([\w\d]{3})\s(AND|OR|XOR)\s([\w\d]{3})\s->\s([\w\d]{3})` in puzzleinput results data(gate_matches).
        loop at gate_matches assigning field-symbol(<g>).
            data(in1_match) = <g>-submatches[ 1 ].
            data(in2_match) = <g>-submatches[ 3 ].
            data(op_match)  = <g>-submatches[ 2 ].
            data(out_match) = <g>-submatches[ 4 ].
            data(in1) = puzzleinput+in1_match-offset(in1_match-length).
            data(in2) = puzzleinput+in2_match-offset(in2_match-length).
            data(op) = puzzleinput+op_match-offset(op_match-length).
            data(out) = puzzleinput+out_match-offset(out_match-length).
            insert value #( in1 = in1 in2 = in2 op = op out = out ) into table gates.
        endloop.
    endmethod.
    method zif_aoc2024~resolve.

        read_puzzle(  puzzleinput ).

        data x type t_64bit.
        data y type t_64bit.
        x = wires_val( 'x'  ).
        y = wires_val(  'y' ).

        make_graph(  ).

        data res type t_64bit.
        res = compute_with_gates( x = x y = y ).

        " Part2
        " idea
        " in the text we have the hint that this gate is an adder.
        " look up in wikipedida: https://en.wikipedia.org/wiki/Carry-lookahead_adder#Expansion
        "  since only 4 swaps were sought for i skipped programming the solution but extracted the swaps manually
        "  the code below helped me testing my solution.
        " nonetheless it would be interesting to code it
        "  2 alternatives:
        "     1. build the correct curry adder, compare and fix differences
        "     2. search for not correct patterns in the given adder and fix then (what I did manually)
        "                                      z(n)
        "                                      XOR
        "                                 OR         XOR
        "                             AND   ...   x(n) y(n)
        "                     x(n-1)   y(n-1)
        "  ... would be hopeless for 2, but fortunatelly not relevant in this quest

        clear x. clear y.
        " need the lengths of x and y...
        data(xlen) = reduce i( init c = 0 for w in wires where ( name cp `x++` ) next c = c + 1 ).
        data(ylen) = reduce i( init c = 0 for w in wires where ( name cp `y++` ) next c = c + 1 ).

        data lineno(2) type c.
        data plineno(2) type c.
        data zi type int8.
        data z type t_64bit.
        data z_gates type t_64bit.
        data(trace) = |{ bits( res ) }\n|.
        y =  'FFFFFFFFFFFFFFFF' .
        x =  'FFFFFFFFFFFFFFFF' .
        zi = conv int8( x ) + conv int8( y ).
        z = conv t_64bit(  zi ).
        z_gates = compute_with_gates( x = y y = x ).
        data(bits_out) = bits( x ).
        plineno = sy-index - 1.
        unpack plineno to lineno.
        trace = |{ trace }\nXX:{ bits( z ) }-{ bits( z_gates ) }|.
        clear x. clear y.
        do xlen times.
            clear x.
            set bit ( 64 - sy-index + 1 ) of x.
            zi = conv int8( x ) + conv int8( y ).
            z = conv t_64bit(  zi ).
            z_gates = compute_with_gates( x = y y = x ).
            bits_out = bits( x ).
            plineno = sy-index - 1.
            unpack plineno to lineno.
            trace = |{ trace }\n{ lineno }:{ bits( z ) }-{ bits( z_gates ) }|.
        enddo.

        " PART 2
        "
" z39 -> (cpm,krs) z33->(z33,ghp), z10->(z10,gpr) z21->(z21,nks)
"cpm,ghp,gpr,krs,nks,z10,z21,z33
"51107420031718
        result = |Part 1: { conv int8( res ) } Part 2: { `TODO` }\n\n{ trace }|. "its 64 bit in total

* the corrected adder
*kpf AND jjs -> qsh
*x10 AND y10 -> gpr
*tkq XOR mvc -> z33
*x44 XOR y44 -> wdg
*y41 AND x41 -> sbj
*sdk AND pcg -> qdc
*bgn AND gdp -> vjj
*scj XOR ptd -> z21
*x41 XOR y41 -> cmn
*y33 XOR x33 -> tkq
*fkn XOR cpp -> z15
*y14 AND x14 -> mgp
*srf AND wdr -> qmp
*rqp AND vdv -> vdc
*ghp XOR hbg -> z34
*tdq XOR tdj -> z11
*dcd XOR cmn -> z41
*x19 AND y19 -> dws
*y03 XOR x03 -> bnn
*wdg AND ftb -> ndp
*y25 XOR x25 -> sqt
*x12 AND y12 -> drb
*fsf OR gpr -> tdj
*x06 AND y06 -> mnv
*x39 XOR y39 -> krs
*y25 AND x25 -> rpg
*x18 AND y18 -> qqm
*y03 AND x03 -> ngv
*y21 XOR x21 -> ptd
*dpm OR hkn -> hnd
*nvr OR srq -> prt
*ctw OR nbs -> kkb
*bkw OR qmp -> gft
*wfc AND bvg -> dpm
*x12 XOR y12 -> kpf
*wpw XOR nwb -> z19
*x11 XOR y11 -> tdq
*x08 AND y08 -> mbt
*x30 AND y30 -> kdb
*y24 XOR x24 -> wfc
*wgw XOR rtj -> z35
*x01 XOR y01 -> cdh
*bqv XOR kkb -> z27
*x16 XOR y16 -> fjt
*wcr XOR bjh -> z05
*y30 XOR x30 -> kwq
*dnb XOR mgr -> z29
*pdq AND ctr -> jhh
*x08 XOR y08 -> rtn
*y04 XOR x04 -> nwv
*krb OR cpm -> jhd
*rcn AND nsj -> dwh
*fhd OR bws -> nwt
*qdc OR gnm -> qgm
*x09 XOR y09 -> gdp
*drt OR qqm -> nwb
*x16 AND y16 -> tqn
*wtc OR ndp -> z45
*nwv AND sdf -> brh
*htv XOR whd -> z10
*mrq XOR pcf -> z26
*gbn OR qcm -> dcd
*rtj AND wgw -> nvr
*jhd AND vvm -> gbn
*rhk OR nks -> hhc
*y01 AND x01 -> knd
*x38 AND y38 -> mph
*dtg OR gjs -> scj
*tnd OR vjj -> whd
*ghp AND hbg -> khh
*y32 XOR x32 -> qnj
*mhr AND krs -> krb
*pcf AND mrq -> nbs
*x14 XOR y14 -> dqw
*sdk XOR pcg -> z42
*rpg OR brs -> pcf
*mgp OR vrc -> fkn
*y23 XOR x23 -> sfc
*drb OR qsh -> vjt
*krs XOR mhr -> z39
*y09 AND x09 -> tnd
*bgn XOR gdp -> z09
*y36 AND x36 -> mkh
*twg XOR rtn -> z08
*ngv OR qtp -> sdf
*rqp XOR vdv -> z06
*cmn AND dcd -> qkb
*vhs XOR kwq -> z30
*wpg OR frb -> ftb
*tqn OR tvk -> nsj
*y37 XOR x37 -> srf
*y39 AND x39 -> cpm
*x27 AND y27 -> dpd
*x04 AND y04 -> ktv
*mph OR sqw -> mhr
*fbc OR smr -> nwk
*nwk XOR fjt -> z16
*vvm XOR jhd -> z40
*nwt AND qnj -> sdj
*rcn XOR nsj -> z17
*fnw OR sdj -> mvc
*wfc XOR bvg -> z24
*y43 XOR x43 -> ptf
*hsk OR jhh -> jrj
*x06 XOR y06 -> rqp
*hwr OR khh -> rtj
*y07 AND x07 -> wgj
*tfg XOR jsg -> z07
*bnn XOR jrj -> z03
*jtg OR trf -> ghp
*y19 XOR x19 -> wpw
*ptd AND scj -> nks
*x44 AND y44 -> wtc
*jsg AND tfg -> gmq
*y27 XOR x27 -> bqv
*bcs XOR vjt -> z13
*gpg OR tjg -> jjs
*x37 AND y37 -> bkw
*x20 AND y20 -> dtg
*skt XOR prt -> z36
*qkb OR sbj -> sdk
*nkp XOR sfc -> z23
*y42 AND x42 -> gnm
*wgj OR gmq -> twg
*tdq AND tdj -> tjg
*prt AND skt -> ppq
*gft XOR vmv -> z38
*y20 XOR x20 -> tff
*jjs XOR kpf -> z12
*srf XOR wdr -> z37
*tsj XOR fnb -> z18
*mkh OR ppq -> wdr
*y26 XOR x26 -> mrq
*tff AND qfd -> gjs
*x40 XOR y40 -> vvm
*y32 AND x32 -> fnw
*fnb AND tsj -> drt
*sfc AND nkp -> rtc
*qnj XOR nwt -> z32
*y33 AND x33 -> jtg
*x02 AND y02 -> hsk
*ftb XOR wdg -> z44
*dqw AND jmk -> vrc
*x26 AND y26 -> ctw
*bjh AND wcr -> bwn
*bcs AND vjt -> tfc
*mnv OR vdc -> tfg
*x18 XOR y18 -> tsj
*y22 XOR x22 -> hrr
*x07 XOR y07 -> jsg
*dws OR fgk -> qfd
*y23 AND x23 -> hhg
*wmr AND shk -> mwr
*y31 AND x31 -> fhd
*x34 XOR y34 -> hbg
*dbf OR dwh -> fnb
*y42 XOR x42 -> pcg
*qrw OR nkw -> vhs
*jrj AND bnn -> qtp
*knd OR hsv -> pdq
*x11 AND y11 -> gpg
*y36 XOR x36 -> skt
*y21 AND x21 -> rhk
*bwn OR tqr -> vdv
*kkb AND bqv -> gnb
*qgm XOR ptf -> z43
*hrr XOR hhc -> z22
*vhs AND kwq -> fpk
*y00 AND x00 -> bwd
*y10 XOR x10 -> htv
*x05 XOR y05 -> bjh
*y15 AND x15 -> fbc
*x22 AND y22 -> bbr
*dqw XOR jmk -> z14
*nwk AND fjt -> tvk
*cdh XOR bwd -> z01
*mwr OR ngk -> mgr
*cpp AND fkn -> smr
*y17 AND x17 -> dbf
*y29 AND x29 -> qrw
*y00 XOR x00 -> z00
*nwb AND wpw -> fgk
*x13 XOR y13 -> bcs
*wmr XOR shk -> z28
*vmv AND gft -> sqw
*x15 XOR y15 -> cpp
*x13 AND y13 -> drw
*jvd OR bbr -> nkp
*mgr AND dnb -> nkw
*x29 XOR y29 -> dnb
*x05 AND y05 -> tqr
*x35 XOR y35 -> wgw
*hnd XOR sqt -> z25
*twg AND rtn -> hnp
*y43 AND x43 -> wpg
*ktv OR brh -> wcr
*x40 AND y40 -> qcm
*y31 XOR x31 -> ggv
*mvc AND tkq -> trf
*drw OR tfc -> jmk
*ctr XOR pdq -> z02
*nwv XOR sdf -> z04
*kdb OR fpk -> dfm
*whd AND htv -> fsf
*dfm AND ggv -> bws
*ggv XOR dfm -> z31
*y28 XOR x28 -> wmr
*y17 XOR x17 -> rcn
*hrr AND hhc -> jvd
*qfd XOR tff -> z20
*cdh AND bwd -> hsv
*hnd AND sqt -> brs
*dpd OR gnb -> shk
*hnp OR mbt -> bgn
*ptf AND qgm -> frb
*rtc OR hhg -> bvg
*y34 AND x34 -> hwr
*x02 XOR y02 -> ctr
*y35 AND x35 -> srq
*x38 XOR y38 -> vmv
*x24 AND y24 -> hkn
*y28 AND x28 -> ngk
*
*
    endmethod.
endclass.