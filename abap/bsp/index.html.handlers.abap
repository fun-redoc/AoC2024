* event handler for checking and processing user input and
* for defining navigation

* following page attributes has to be provided
*
* day	        TYPE	    STRING	
* puzzleinput	TYPE	    STRING	
* result	    TYPE	    STRING	
* solution	    TYPE REF TO	ZIF_AOC2024	


* Handler for the Event: `OnInputProcessing`

case event_id.

when 'Run'.
  puzzleinput = request->get_form_field( 'input' ).
  day = request->get_form_field( 'day' ).

  " here call the real solution method
  data(impl) = 'ZCLAOC2024_DAY' && day.
  create object solution type (impl).

  result = solution->resolve( puzzleinput ).

endcase.