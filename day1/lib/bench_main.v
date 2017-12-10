/****h* tango/bench_main
 *
 * NAME
 *   bench_main
 * USED BY
 *   all main module
 * HISTORY
 *   02/02/2009 - initial version
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@sdesigns.eu
 * DESCRIPTION
 *   This module contains necessary tools for all simulations
 *
 *   It should be instantiated in all top of simulation
 *
 * SOURCE
 */

module bench_main (input clk);

  reg ready;

  // exit status handling

  reg [7:0] exit_status = 8'd0;

  function void report_error(input [7:0] i);
    begin
      exit_status = exit_status | i;
    end
  endfunction

  task exit(input [7:0] i);
    begin
      exit_status = exit_status | i;
      if (^exit_status === 1'bx)
        exit_status = 1;
      // this line is parsed by sigm_simu_run to obtain the simulation exit
      // status
      $fwrite(log.error, "%t > SIMULATION ENDS WITH EXIT STATUS %0d\n",
              $realtime, exit_status);
      $write("$finish ");
      $stacktrace;
      $finish;
    end
  endtask

  longint clk_count;

  initial
  begin
    // clear file that will be appended at end of simulation
    $fclose($fopen("output/ram_stats.log", "w"));
    $timeformat(-9, 0, " ns", 20);
    clk_count = 0;
    ready = 1'b1;
  end

  always @(posedge clk)
    clk_count <= clk_count + 1;

  event stop_simulation;
  always @(stop_simulation)
  begin
    #1;
    $stop;
  end

  final
  begin
    final_block;
  end

  function void final_block();
  begin
    if (clk_count != 0)
      `SIGM_PRINT(`SIGM_NOTICE, ("For info : simulation took %0d cycles\n", clk_count));
  end
  endfunction

endmodule

/***/
