class zclaoc2024_day17 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        x1 type x length 8,
        begin of t_register,
            name type char1,
            value type int8,
        end of t_register,
        begin of t_mnem,
            code type i,
            name type string,
            operands type int8,
            "...
        end of t_mnem,
        tt_program type standard table of i with empty key.
    data:
        A type t_register,
        B type t_register,
        C type t_register,
        program type tt_program,
        pc type i,
        output type standard table of i with empty key,
        failure type abap_bool value abap_false,
        failure_message type string value 'no errors.',
        trace type string value ``.
    methods:
        get_reg importing reg type char1 returning value(res) type int8,
        set_reg importing reg_name type char1 value type int8,
        dump returning value(d) type string,
        get_combo importing operand type int8 returning value(val) type int8,
        get_mnem importing op type i returning value(mnem) type t_mnem,
        run_mnem importing mnem type t_mnem,
        run_program importing trace_it type abap_bool optional,
        append_to_output importing v type i,
        " yes I know its not the shortest way to imlement this,,,,but its for fun..
        xdv importing x type char1 operand type int8,
        adv importing operand type int8,
        bxl importing operand type int8,
        bst importing operand type int8,
        jnz importing operand type int8,
        bxc importing operand type int8,
        out importing operand type int8,
        bdv importing operand type int8,
        cdv importing operand type int8,
        read_puzzle importing puzzleinput type string.
ENDCLASS.



CLASS ZCLAOC2024_DAY17 IMPLEMENTATION.


    method adv.
        xdv( x = 'A' operand = operand ).
    endmethod.


    method append_to_output.
        append v to output.
    endmethod.


    method bdv.
        xdv( x = 'B' operand = operand ).
    endmethod.


    method bst.
        data(operand_value) = get_combo( operand ).
        if failure ne abap_true.
            data(aux) = operand_value mod 8.
            set_reg( reg_name = 'B' value = aux ).
        endif.
    endmethod.


    method bxc.
        data operand_value_b type x1.
        data operand_value_c type x1.
        operand_value_b = conv x1( B-value ).
        operand_value_c = conv x1( C-value ).
        if failure ne abap_true.
            data(aux) = operand_value_b bit-xor  operand_value_c.
            data(res) = conv int8( aux ).
            set_reg( reg_name = 'B' value = res ).
        endif.
    endmethod.


    method bxl.
        data operand_value type x1.
        operand_value = conv x1( operand ).
        if failure ne abap_true.
            data(aux) = conv x1( B-value ) bit-xor  operand_value.
            data(res) = conv int8( aux ).
            set_reg( reg_name = 'B' value = res ).
        endif.
    endmethod.


    method cdv.
        xdv( x = 'C' operand = operand ).
    endmethod.


    method dump.
        d = |A:{ A-value }, B:{ B-value }, C:{ C-value },| &&
            |PC: { pc }\n| &&
            |code:{ reduce string( init i = 1 s = `` for p in program next i = i + 1 s = s && cond #( when i eq pc then |\|{ p }\|,| else  |{ p },| ) ) }\n| &&
            |out:{ reduce string( init s = || for o in output next s = s && |{ o },| ) }\n|.
    endmethod.


    method get_combo.
    "Combo operands 0 through 3 represent literal values 0 through 3.
    "Combo operand 4 represents the value of register A.
    "Combo operand 5 represents the value of register B.
    "Combo operand 6 represents the value of register C.
    "Combo operand 7 is reserved and will not appear in valid programs.

        if operand > 6.
            failure = abap_true.
            failure_message = |combo operand cannot have a value { operand } bigger than 6 at pc={ pc }.|.
        else.
            val = cond int8(
                when operand between 0 and 3 then operand
                when operand eq 4 then A-value
                when operand eq 5 then B-value
                when operand eq 6 then C-value
            ).
        endif.

    endmethod.


    method get_mnem.
        case op.
            when 0. mnem = value #( code = 0 name = 'adv' operands = 1 ). " i badly needed function pointers or lambdas ...
            when 1. mnem = value #( code = 1 name = 'bxl' operands = 1 ).
            when 2. mnem = value #( code = 2 name = 'bst' operands = 1 ).
            when 3. mnem = value #( code = 3 name = 'jnz' operands = 1 ).
            when 4. mnem = value #( code = 4 name = 'bxc' operands = 1 ).
            when 5. mnem = value #( code = 5 name = 'out' operands = 1 ).
            when 6. mnem = value #( code = 6 name = 'bdv' operands = 1 ).
            when 7. mnem = value #( code = 7 name = 'cdv' operands = 1 ).
        endcase.
    endmethod.


    method get_reg.
        case reg.
            when 'A'. res = A-value.
            when 'B'. res = B-value.
            when 'C'. res = C-value.
            when others.
                failure = abap_true.
                failure_message = |unknow register { reg } at pc={ pc }.|.
        endcase.
    endmethod.


    method jnz.
        data(new_pc) = A-value.
        if A-value ne 0.
            pc = operand.
        else.
            add 1 to pc.
        endif.
    endmethod.


    method out.
        data(operand_value) = get_combo( operand ).
        if failure ne abap_true.
            data(aux) = conv i( operand_value mod 8 ).
            append_to_output( aux ).
        endif.
    endmethod.


    method read_puzzle.
        data(lines) = split_into_lines( puzzleinput ).
        loop at lines assigning field-symbol(<line>).
"Register A: 729
"Register B: 0
"Register C: 0
"
"Program: 0,1,5,4,3,0
            find all occurrences of regex `^(Register) ([ABC]): (\d+)|(\d+)`
                in <line> submatches data(dump_area) data(dump_register) data(dump_data) results data(matches).
            case dump_area.
                when 'Register'.
                    data(register) = conv char1( dump_register ).
                    data(register_val) = conv int8( dump_data ).
                    set_reg( reg_name = register value = register_val ).
                when others.
                    loop at matches assigning field-symbol(<m>).
                       data(opcode) = conv i( <line>+<m>-offset(<m>-length) ).
                       append opcode to program.
                    endloop.
            endcase.
        endloop.
    endmethod.


    method run_mnem.
            if mnem-operands eq 1.
                add 1 to pc.
                if pc >= lines(  program ).
                    failure = abap_true.
                    failure_message = |operand expected but program ended.|.
                    exit.
                else.
                    data(operand) = program[ pc + 1 ].
                endif.
                case mnem-code.
                    when 0. adv( conv int8( operand ) ). add 1 to pc. " i badly needed function pointers or lambdas ...
                    when 1. bxl( conv int8( operand ) ). add 1 to pc.
                    when 2. bst( conv int8( operand ) ). add 1 to pc.
                    when 3. jnz( conv int8( operand ) ). " cause it sets pc
                    when 4. bxc( conv int8( operand ) ). add 1 to pc.
                    when 5. out( conv int8( operand ) ). add 1 to pc.
                    when 6. bdv( conv int8( operand ) ). add 1 to pc.
                    when 7. cdv( conv int8( operand ) ). add 1 to pc.

                endcase.
            else.
                    failure = abap_true.
                    failure_message = |exactly 1 operand expected at { pc } intr: { mnem-name }.|.
                    exit.
            endif.

    endmethod.


    method run_program.
        data(prog_len) = lines( program ).
        data(halt) = abap_false.
        while not halt eq abap_true and not failure eq abap_true.
            if trace_it is supplied and trace_it eq abap_true.
                trace = |{ trace }\n{  dump(  ) }|.
            endif.
            data(op) = program[ pc + 1 ].
            data(mnem) = get_mnem( op ).
            run_mnem( mnem ).
            if pc >= prog_len.
                halt = abap_true.
            endif. " one  off errors again...
        endwhile.
    endmethod.


    method set_reg.
        case reg_name.
            when 'A'. A-value = value.
            when 'B'. B-value = value.
            when 'C'. C-value = value.
            when others.
                failure = abap_true.
                failure_message = |unknow register { reg_name } at pc={ pc }.|.
        endcase.
    endmethod.


    method xdv.
        data(operand_value) = get_combo( operand ).
        if failure ne abap_true.
            data(aux) = conv int8( 2 ** operand_value ).
            data(res) = get_reg( reg = 'A' ) div aux.
            set_reg( reg_name = x value = res ).
        endif.
    endmethod.


    method zif_aoc2024~resolve.
    " OK thats a lot to read.
    " or first things first...
    " 1. first read and parse the quest, than
    " 2. implement the instruction interpreter per instruction
    " 3. implement program interpreter
    " 4. collect result

    read_puzzle( puzzleinput ).

    data(trace_it) = abap_true.
    pc = 0.
    run_program( trace_it ).

    data(result_part1) = reduce string( init s = || for o in output next s = s && o && `,` ).
    if strlen( result_part1 ) > 0.
        result_part1 = shift_right( val = result_part1 places = 1 ).
    endif.

" 461301317 is wrong
    if failure eq abap_true.
        result = 'Error: ' && failure_message.
    else.
        result = |Part 1: { result_part1 }|.
    endif.
    if trace_it eq abap_true.
        result = result && trace && |\n{ dump(  ) }|.
    endif.
" run out of time.... see you later...
" no idea, everything seems to run smoothly but the result is wrong, did I overlook something importan?

    endmethod.
ENDCLASS.