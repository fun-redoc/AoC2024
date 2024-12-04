class zclaoc2024_day4_matrix definition
  public
  final
  create public .

  public section.
    types:
       cell_type type c length 1,
       cells_type type table of cell_type with empty key.
    data:
        rows type i,
        cols type i,
        cells type cells_type.
    methods:
        constructor importing rows type i cols type i,
        put_row_from_string importing content type string row type i,
        put importing x type i y type i v type c,
        get importing x type i y type i returning value(v) type cell_type.
  protected section.
  private section.
    methods:
        cell_idx_from_coords importing x type i y type i returning value(idx) type i.
endclass.

class zclaoc2024_day4_matrix implementation.
    method constructor.
    " matrix will be represented as a field of chars
    " in the contructor i create an empty field (matrix) filled with
    " spaces. trying another syntactiv variant of for-expression
        clear cells.
        me->rows = rows.
        me->cols = cols.
        data(n_cells) = rows * cols.
        me->cells = value cells_type( for idx = 1 while idx le n_cells (  space  ) ).
    endmethod.
    method cell_idx_from_coords.
        " TODO bounds checks??
        idx = x + ( y - 1 ) * cols.
    endmethod.
    method get.
        data(cell_idx) = cell_idx_from_coords( x = x  y = y ).
        v = cells[  cell_idx ].
    endmethod.
    method put.
        data(cell_idx) = cell_idx_from_coords( x = x  y = y ).
        cells[  cell_idx ] = v.
    endmethod.
    method put_row_from_string.
        " TODO bounds checks??
        data(len) = strlen(  content ).
        if len ne cols.
            raise exception type cx_fatal_exception.
        endif.
        " the one-off errors are the best
        do len times.
            data(off) = sy-index - 1.
            data(ch) = content+off(1).
            data(cell_idx) = cell_idx_from_coords( x = ( off  + 1 ) y = row ).
            cells[ cell_idx ] = ch.
        enddo.
    endmethod.
endclass.