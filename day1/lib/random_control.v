/****h* tango/random_control
 *
 * NAME
 *   random_control
 * USED BY
 *   bench files
 * HISTORY
 *   15/03/2004 - initial version
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@realmagic.fr
 * DESCRIPTION
 *   This module generates a random control signal (vld or rdy)
 *
 *   The random signal can have a constant rate for all the simulation (defined
 *   by the constant_rate parameter) or can change from min_rate to max_rate
 *
 *   The output is not related to the input signal by default
 *   (random_behavior=0)
 *   If random_behavior=1, once the output gets 1 it doesn't get random until
 *   the next transaction.
 *
 *   Task 
 *     start                                    : start the generation of output
 *     stop                                     : stop
 *     set_constant_rate (rate)                 : set a constant rate
 *     set_variable_rate (min, max, period)     : set a variable rate changing
 *                                                from min to max in period clk
 *     set_random_behavior (random_behavior)    : change behavior of random
 *     set_burst_control (value)                : when variable rate is close to
 *                                                min or max rate act like
 *                                                famine or burst
 *
 * SOURCE
 */


module random_control (clk, control_in, control_out);

//-------------- Interface -----------------------

  parameter constant_rate       = ""; // constant random
  parameter random_period       = 1000;
  parameter min_rate            = 0;
  parameter max_rate            = 100;
  parameter random_behavior     = 0;
  parameter burst_control       = 10;


  input                         clk;
  input                         control_in;
  output                        control_out;

  bit                           control_out_before_pattern;
  bit                           control_in_before_pattern;

//-------------- Internal variables --------------

  integer                       _random_period;
  integer                       _min_rate;
  integer                       _max_rate;

  integer                       current_rate;
  reg                           running;
  reg                           internal_running;

  integer                       nr_transaction;
  reg                           do_constant_rate;
  integer                       increment;
  integer                       increment_period;
  
  integer                       stop_in_count_transaction;
  reg                           _random_behavior;
  integer                       _burst_control;

  initial
    begin
      control_out_before_pattern = 0;
      running = 0;
      _random_behavior = random_behavior;
      _burst_control = burst_control;
      if (constant_rate != "")
        set_constant_rate (constant_rate);
      else
        set_variable_rate (min_rate, max_rate, random_period);
    end

  always @(posedge clk)
    begin
      if (!do_constant_rate && running)
        begin
          nr_transaction = nr_transaction + 1;
          if (nr_transaction % increment_period == 0)
            current_rate = current_rate + 2 * increment - 1;
          if (current_rate >= _max_rate)
            increment = 0;
          if (current_rate <= _min_rate)
            increment = 1;
          
        end
    end


  wire burst  = ((100 - current_rate) <= _burst_control) && !do_constant_rate;
  wire famine = (current_rate <= _burst_control) && !do_constant_rate;

  integer f;
  integer r;
  always @(posedge clk)
    begin
      if (control_in_before_pattern & control_out_before_pattern && stop_in_count_transaction > 0)
        begin
          stop_in_count_transaction = stop_in_count_transaction - 1;
          if (stop_in_count_transaction == 0)
          begin
            running = 0;
            internal_running = 0;
          end
        end
      if (internal_running)
        begin
          f = $urandom; // abs ?
          if (f < 0)
            f = - f;
          r = (f % 100);
          control_out_before_pattern <= ((r < current_rate) & ~famine || burst) ||
                            _random_behavior && control_out_before_pattern && ~control_in_before_pattern;
        end
      else
        control_out_before_pattern <= 1'b 0;
    end



//************** Start,Stop  tasks *******************

  // count > 0 : stop after count output
  // count = 0 : don't stop
  task start;
      input integer     count;
    begin
      stop_in_count_transaction = count;
      internal_running = 1;
      running = 1;
    end
  endtask

  task stop;
    begin
      internal_running = 0;
      running <= 0;
    end
  endtask

  task set_constant_rate;
      input integer     rate;
    begin
      do_constant_rate = 1;
      current_rate = rate;
    end
  endtask

  task set_variable_rate;
      input integer     min;
      input integer     max;
      input integer     period;
    begin
      do_constant_rate = 0;
      _random_period = period;
      _min_rate = min;
      _max_rate = max;
      current_rate = (min + max) >> 1;
      nr_transaction = 0;
      increment = 1;
      increment_period = period / (max - min);
    end
  endtask

  task set_random_behavior;
      input reg         behavior;
    begin
      _random_behavior = behavior;
    end
  endtask

  task set_burst_control;
      input integer     value;
    begin
      _burst_control = value;
    end
  endtask

// by default stream_pattern let go the control unchanged...
stream_pattern stream_pattern(
  .clk(clk),
  .in_vld(control_out_before_pattern),
  .in_rdy(control_in_before_pattern),
  .out_rdy(control_in),
  .out_vld(control_out)
  );

endmodule

/***/
