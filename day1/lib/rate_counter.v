/****h* tango/rate_counter
 *
 * NAME
 *   rate_counter
 * USED BY
 *   bench files
 * HISTORY
 *   11/03/2004 - initial version
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@realmagic.fr
 * DESCRIPTION
 *   This module computes an utilization rate.
 *
 *   An instantaneous rate is computed on a variable window size.
 *   An average rate is computed for all the simulation since the first
 *   transaction.
 *
 *   start and stop tasks restarts or stops the computation of the average rate
 *   set_windows_size set the window size for the instantaneous rate computation
 *
 * SOURCE
 */


module rate_counter (clk, vld, rdy);

//-------------- Interface -----------------------

  parameter             window_size = 64;

  input                 vld;
  input                 rdy;
  input                 clk;

  integer               _maximum_rate;          // maximum instant rate
  integer               _instant_rate;          // average rate on the window
  integer               _average_rate;          // rate on all the simulation



//-------------- Internal variables --------------


`define MULT            100

  integer               _window_size;
  integer               nr_clock_cycles;        // number of clock cycles since
                                                // the first transaction

  reg [window_size-1:0] is_trans;
  reg                   is_started;
  integer               total_transaction;
  integer               nr_trans;               // number of transaction in the
                                                // window

  reg                   activated;              // total count is activated
  wire                  trans;                  // a transaction occurs



  //integer i; 
  // TODO ? create an array of instante rate for window of 1 clock =>
  // window_size clock.
  // Problem : how to show this array in the wave form...
  initial
    begin
      _window_size = window_size;
      _maximum_rate = 0;
      _average_rate = 0;
      nr_clock_cycles = 0;
      is_trans = 0;
      is_started = 0;
      total_transaction = 0;
      nr_trans = 0;
      activated = 1;
      _instant_rate = 0;
      //for (i = 0; i < window_size; i = i + 1)
      //  instant_rate[i] = 0;
    end

  assign trans = (vld === 1'b1) && (rdy === 1'b1);

  /*
   * counts the transaction in the window for instant rate
   */

  always @(posedge clk)
    is_trans[window_size - 1:0] <= {is_trans[window_size - 2:0], trans};

  integer               i;
  always @(posedge clk)
    begin
`ifdef NO_VARIABLE_WINDOW_SIZE
      nr_trans = nr_trans - is_trans[window_size-1] + trans; // no var win
`else
      nr_trans = 0;
      for (i = 0; i < _window_size; i = i + 1)
        nr_trans = nr_trans + is_trans[i];
`endif
      //instant_rate[i] = nr_trans (i) / (i + 1);
    end

  //function integer nr_trans;
  //    input integer     window;
  //  begin
  //    nr_trans = 0;
  //    for (i = 0; i <= window; i = i + 1)
  //      nr_trans = nr_trans + is_trans[i];
  //  end
  //endfunction

  always @(posedge clk)
    begin
      _instant_rate = `MULT * nr_trans / _window_size;
      if (_instant_rate > _maximum_rate)
        _maximum_rate = _instant_rate;
    end

  /*
   * counts the number of clock cycles and the number of transaction since the
   * first transaction for average rate
   */
  always @(posedge clk)
    begin
      if (trans && activated)
        begin
          is_started = 1;
          total_transaction = total_transaction + 1;
        end
      if (is_started)
        begin
          nr_clock_cycles = nr_clock_cycles + 1;
          _average_rate = `MULT * total_transaction / nr_clock_cycles;
        end
    end

// ************** Start, Stop tasks *******************

  task start;
    activated = 1;
  endtask

  task stop;
    begin
      activated = 0;
      total_transaction = 0;
      nr_clock_cycles = 0;
      is_started = 0;
    end
  endtask

  task set_windows_size;
      input integer size;
    begin
      if (size <= window_size)
        _window_size = size;
    end
  endtask

endmodule

/***/
