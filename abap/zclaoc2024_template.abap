class zclaoc2024_day1 definition
  public
  final
  inheriting from zclaoc2024_base
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.

  protected section.
  
  private section.
endclass.



class zclaoc2024_day1 implementation.

  method zif_aoc2024~resolve.
*    using methods from base class
*      split_into_lines importing s type string returning value(lines) type tt_string.

    data(lines) = split_into_lines( puzzleinput ).

    " my rolution code comes here

    result = `TODO: assign the solution to the result returning parameter here`.
  endmethod.

endclass.