class zclaoc2024_day8 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition,
      constructor.
  protected section.
  private section.
    types:
      begin of t_antena,
        a type c length 1,
        x type i,
        y type i,
      end of t_antena,
      tt_antena type standard table of t_antena with empty key, " maybe for perfoamnce some keys will become handy
      begin of t_pair_of_antenas,
        a1 type t_antena,
        a2 type t_antena,
        dx type i,
        dy type i,
      end of t_pair_of_antenas,
      tt_pairs_of_antenas type table of t_pair_of_antenas with unique hashed key antenas components a1 a2,
      tt_antinodes type table of zclaoc2024_day4_matrix=>t_v2 with non-unique key primary_key components x y.
      .
    data:
      mat     type ref to zclaoc2024_day4_matrix,
      antenas type tt_antena,
      pairs type tt_pairs_of_antenas,
      antinodes type tt_antinodes.
    methods:
      read_puzzle importing puzzleinput type string,
      make_pairs,
      make_antinodes,
      mk_antinodes_w_resonant_harms
      .
endclass.



class zclaoc2024_day8 implementation.
  method constructor.
    super->constructor( ).
    " Welcome to Day 8 of 2024's Advent of COde
    " I hope you enjoy coding with me
  endmethod.

  method mk_antinodes_w_resonant_harms.
    " it seems the antenas can be antinodes themselves?
    clear antinodes.
    loop at pairs assigning field-symbol(<p>).
        append value #( x = <p>-a1-x y = <p>-a1-y ) to antinodes.
        append value #( x = <p>-a2-x y = <p>-a2-y ) to antinodes.
        " ray back
        data(anti) = value zclaoc2024_day4_matrix=>t_v2(
                         x = ( <p>-a1-x - <p>-dx )
                         y = ( <p>-a1-y - <p>-dy )
                      ).
        while mat->check_in_bounds( anti ) eq abap_true.
            append anti to antinodes.
            data(x1) = ( anti-x - <p>-dx ).
            data(y1) = ( anti-y - <p>-dy ).
            anti = value zclaoc2024_day4_matrix=>t_v2( x = x1 y = y1 ).
        endwhile.

        " ray forward
        data(anti2) = value zclaoc2024_day4_matrix=>t_v2(
                         x = ( <p>-a2-x + <p>-dx )
                         y = ( <p>-a2-y + <p>-dy )
                      ).
        while mat->check_in_bounds( anti2 ) eq abap_true.
            append anti2 to antinodes.
            data(x2) = ( anti2-x + <p>-dx ).
            data(y2) = ( anti2-y + <p>-dy ).
            anti2 = value zclaoc2024_day4_matrix=>t_v2( x = x2 y = y2 ).
        endwhile.
    endloop.
  endmethod.

  method make_antinodes.
    loop at pairs assigning field-symbol(<p>).
        data(anti1) = value zclaoc2024_day4_matrix=>t_v2(
                         x = <p>-a1-x - <p>-dx
                         y = <p>-a1-y - <p>-dy
                      ).
        data(anti2) = value zclaoc2024_day4_matrix=>t_v2(
                         x = <p>-a2-x + <p>-dx
                         y = <p>-a2-y + <p>-dy
                      ).
        if mat->check_in_bounds( anti1 ).
            append anti1 to antinodes.
        endif.
        if mat->check_in_bounds( anti2 ).
            append anti2 to antinodes.
        endif.
    endloop.
  endmethod.

  method make_pairs.
    loop at antenas assigning field-symbol(<a1>).
        loop at antenas assigning field-symbol(<a2>).
            if <a1> ne <a2>. " i think ABAP is smart enoug to compare based on content...
                if <a1>-a eq <a2>-a. "pairs of same type
                    data(pair) =
                        value t_pair_of_antenas( a1 = <a1>
                                                 a2 = <a2>
                                                 dx = ( <a2>-x - <a1>-x )
                                                 dy = ( <a2>-y - <a1>-y ) ).
                        " <a1>-x + dx == <a2>-x; <a1>-y + dy == <a2>-y
                    read table pairs with key antenas components a1 = <a2> a2 = <a1> transporting no fields.
                    if sy-subrc eq 4.
                        append pair to pairs.
                    endif.
                endif.
           endif.
        endloop.
    endloop.
  endmethod.


  method read_puzzle.
    " single lowercase letter, uppercase letter, or digit
    data(lines) = split_into_lines( puzzleinput ).
    data(rows) = lines( lines ).
    data(cols) = strlen( lines[ 1 ] ). "assume all lines have same length
    mat = new #( rows = rows cols = cols ).
    " find does not behave like i thought...
    " returning to my classical approach..
    loop at lines assigning field-symbol(<line>).
        data(y) = sy-tabix.
        find all occurrences of regex `[a-zA-Z0-9]`
            in <line>
            results data(matches).
        loop at matches assigning field-symbol(<m>).
          data(x) = <m>-offset + 1. " offset is 0 based
          assert <m>-length eq 1.
          data(a) = conv zclaoc2024_day4_matrix=>cell_type(  <line>+<m>-offset(1) ).
          mat->put( x = x y = y v = a ).
          append value t_antena( a = a x = x y = y ) to antenas.
        endloop.
    endloop.
  endmethod.

  method zif_aoc2024~resolve.
    read_puzzle(  puzzleinput ).


    "at any point that is perfectly in line with two antennas of the same frequency
    " - but only when one of the antennas is twice as far away as the other.
    make_pairs(  ).

    " PART 1
    " make_antinodes( ).

    " Part 2
    mk_antinodes_w_resonant_harms( ).

    data unique_antinodes like antinodes.
    unique_antinodes = antinodes.
    sort unique_antinodes.
    delete adjacent duplicates from unique_antinodes.

    data(result_part2) = lines(  unique_antinodes ). " only for checking the parser
    result = | Part 2: { result_part2 } |.
  endmethod.
endclass.