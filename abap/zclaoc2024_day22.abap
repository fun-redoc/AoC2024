class zclaoc2024_day22 definition
  public
  inheriting from zclaoc2024_base
  final
  create public .

  public section.
    methods: zif_aoc2024~resolve redefinition.
  protected section.
  private section.
    types:
        begin of t_price_entry,
            price type i, " the sore mod 10
            delta type i, "need negatives
            " i think some mor will come
        end of t_price_entry,
        tt_prices type standard table of t_price_entry with empty key initial size 2000,
        tt_secret_inits type standard table of int8 with empty key initial size 2000,
        tt_delta_sequence type standard table of i with empty key,
        begin of t_sequence_yield,
            delta_sequence_hash type i,
            price type i,
        end of t_sequence_yield,
        tt_sequence_yield type hashed table of t_sequence_yield with unique key delta_sequence_hash,
        begin of t_buyer,
            secret_init type int8,
            prices type tt_prices,
            yield type tt_sequence_yield,
        end of t_buyer,
        tt_buyers type standard table of t_buyer with empty key.
    data:
        delta_sequence_hashes type hashed table of i with unique key table_line,
        buyers type tt_buyers.
    methods:
        xor importing v1 type int8 v2 type int8 returning value(res) type int8,
        calculation importing secret type int8 returning value(next_secret) type int8,
        find_sequence_yields_for_buyer changing buyer type t_buyer,
        find_sequence_yields,
        most_bananas returning value(res) type i,
        read_puzzle importing puzzleinput type string.
endclass.



class zclaoc2024_day22 implementation.

    method most_bananas.
        data(max_price) = 0.
        data(acc_price) = 0.
        data(buyer_price) = 0.
        loop at delta_sequence_hashes assigning field-symbol(<dsh>).
            acc_price = 0.
            loop at buyers assigning field-symbol(<buyer>).
                read table <buyer>-yield with key delta_sequence_hash = <dsh> assigning field-symbol(<yield>).
                if sy-subrc eq 0.
                    buyer_price = <yield>-price.
                else.
                    buyer_price = 0.
                endif.
                acc_price = acc_price + buyer_price.
            endloop.
            if max_price < acc_price.
                max_price = acc_price.
             endif.
        endloop.

        res = max_price.
    endmethod.

    method find_sequence_yields_for_buyer.
        data li type i. " left index
        data ri type i. " right index
        data subseq type standard table of i with empty key.

        " assumption
        if lines( buyer-prices ) ne 2000.
            raise  exception type cx_fatal_exception.
        endif.

        do 2000 - 3  times.
           li = sy-index .
           ri = sy-index  + 3.
           " values are between -9 and 9 -> (+9) -> 0 and 18
           data(hash_seq) = buyer-prices[ li ]-delta + 9 .  " 18 / 9
           hash_seq = hash_seq + 100 * ( buyer-prices[ li + 1 ]-delta + 9 ). " 18 + 18*100 = 18 + 1800 = 1818 / 9 + 9*100 = 9 + 900 = 909
           hash_seq = hash_seq + 10000 * ( buyer-prices[ li + 2 ]-delta + 9 ). " 1818 + 10000*18 = 1818+180000 = 181818 / 909 + 9+10000 = 909 + 90000 = 90909
           hash_seq = hash_seq + 1000000 * ( buyer-prices[ li + 3 ]-delta + 9 ). " 181818 + 18*1000000 = 181818+18000000 = 18181818 / 90909 +9*1000000 = 90909 + 9000000 = 9090909

            " IDEA
            " comute a hash so that a delta sequence is easy to find (as key in a hash map)
            " store for each delta sequence hash the highest price the buyer is willing to pay for that seq.
            read table buyer-yield with key delta_sequence_hash = hash_seq assigning field-symbol(<yield>).
            if sy-subrc ne 0.
                insert value #( delta_sequence_hash = hash_seq price = buyer-prices[ ri ]-price ) into table buyer-yield.
                insert hash_seq into table delta_sequence_hashes.
            else.
                if <yield>-price < buyer-prices[ ri ]-price.
                    insert value #( delta_sequence_hash = hash_seq price = buyer-prices[ ri ]-price ) into table buyer-yield.
                endif.
            endif.

        enddo.

    endmethod.
    method find_sequence_yields.
        loop at buyers assigning field-symbol(<buyer>).
            find_sequence_yields_for_buyer( changing buyer = <buyer>  ).
        endloop.
    endmethod.
    method read_puzzle.
        data(lines) = split_into_lines( puzzleinput ).
        loop at lines assigning field-symbol(<line>).
            append value #( secret_init =  conv int8( <line> ) ) to buyers.
        endloop.
    endmethod.
    method xor.
        types t_bin8 type x length 8.
        data xv1 type t_bin8.
        data xv2 type t_bin8.
        xv1 = conv t_bin8( v1 ).
        xv2 = conv t_bin8( v2 ).
        data(xres) = xv1 bit-xor xv2.
        res = conv int8( xres ).
        " issue may arise with int8 beeing negative
        " check it
        if res < 0 .
            raise exception type cx_fatal_exception.
        endif.
    endmethod.
    method calculation.
        data(step1) = secret * 64.
        data(step1mix) = xor( v1 = secret v2 = step1 ).
        data(step1prune) = step1mix mod 16777216.
        data(step2) = step1prune div 32.
        "data(step2mix) = xor( v1 = secret v2 = step2 ).
        data(step2mix) = xor( v1 = step1prune v2 = step2 ).
        data(step2prune) = step2mix mod 16777216.
        data(step3) = step2prune * 2048.
        "data(step3mix) = xor(  v1 = secret v2 = step3 ).
        data(step3mix) = xor(  v1 = step2prune v2 = step3 ).
        data(step3prune) = step3mix mod 16777216.
        next_secret = step3prune.
    endmethod.
    method zif_aoc2024~resolve.
        " seems realtivelly straight foreward, but not part2
        clear buyers.
        read_puzzle( puzzleinput ).

        data result_part1 type int8 value 0.
        data next_price type i.
        data prev_price type i.
        data delta type i.
        loop at buyers assigning field-symbol(<buyer>).
            data(previous_secret) = <buyer>-secret_init.
            prev_price = previous_secret mod 10.
            do 2000 times.
                data(next_secret) = calculation( previous_secret ).
                next_price = next_secret mod 10.
                delta = next_price - prev_price.

                append value #( price = next_price delta = delta  ) to <buyer>-prices. "no delta

                previous_secret = next_secret.
                prev_price = next_price.
            enddo.
            add next_secret to result_part1.
        endloop.


        " step 1: store the last position and delta to predecessor
        " step 2: find the 4-delta-sequence which yields the highest price overall

* thinking...
* 0001 [( 0, [(a,b,c,d), (x,y,z,w)]), (1,....), (2,...)...(9,....) )] <- yields with sequences for single start value out 0f 2000
* ...
* 2000 [( 0, [(a,b,c,d), (x,y,z,w)]), (1,....), (2,...)...(9,....) )] <- yields with sequences for single start value out 0f 2000
* find which combination of those 2000 has the highest yield overall - sequences not availiable also relvant.

        find_sequence_yields(  ).

        " find now the sequence which yealds the most bananas
        data(result_part2) = most_bananas(  ).

" lets debug now, ....

        result = |Part 1: { result_part1 } Part 2: { result_part2 }|.
    endmethod.
endclass.