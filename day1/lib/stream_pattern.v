/****h* tango/stream_pattern
 *
 * NAME
 *   stream_pattern
 * USES
 *
 * USED BY
 *   bench files
 * HISTORY
 *   25/04/2013 - initial version
 * AUTHOR
 *   Thomas Gambier mailto:thomas_gambier@sigmadesigns.com
 * DESCRIPTION
 *   This module receives data from a fifo with a rdy always at 1
 *   and sends data to a fifo with a vld respecting a pattern (if input valid permits it)
 *   If input vld doesn't let the data follow the pattern, the pattern can shift
 *   or accumulate and try to readapt later
 *
 * Tasks
 *   start
 *   stop
 *   set_pattern
 *
 * SOURCE
 */

module stream_pattern (in_vld, in_rdy, out_vld, out_rdy, clk);

//-------------- Interface -----------------------

  parameter max_pattern_size    = 32; // this will be the maximum size of the pattern you can use
  parameter mode                = 0; // when input vld is low whereas we should be valid in output :
                                     // if 0 : wait till input vld
                                     // if 1 : continue the pattern but try to compensate later
                                     // if 2 : strictly follow the pattern

  input                         clk;
  output                        in_rdy;
  input                         in_vld;
  input                         out_rdy;
  output                        out_vld;




  bit                           running;
  reg [max_pattern_size-1 : 0]  pat;
  int                           pat_size;

  int                           current_bit;
  integer                       late;

  wire                          cur_pat = pat[current_bit];

initial
begin
  pat = 1;      // by default no pattern
  pat_size = 1; // by default no pattern
  current_bit = 0;
  late = 0;
  if (mode != 1)
    running = 1;
  else
    running = 0;
end

always @(posedge clk)
begin
  if ( running &&
       ( ((mode == 0) && ((in_vld && out_rdy) || !cur_pat)) || (mode == 1) || (mode == 2))
    )
    current_bit <= (current_bit + 1) % pat_size;
end

generate if (mode == 1)
  always @(posedge clk)
  begin
    if ( !(in_vld && out_rdy) && (pat[current_bit]))
      late <= late + 1;
    if ( (in_vld && out_rdy) && (!pat[current_bit]))
      late <= (late > 0) ? (late - 1) : 0;
  end
endgenerate

assign out_vld = in_vld && running && (cur_pat || (late > 0));
assign in_rdy = out_rdy && running && (cur_pat || (late > 0));


task start;
  running = 1;
endtask

task stop;
  running = 0;
endtask

task set_pattern(input [max_pattern_size-1 : 0] _pattern, input int _pattern_size);
  begin
    if (_pattern_size > max_pattern_size)
      `SIGM_ASSERT(0, ("In %m, the pattern_size cannot be larger than the max_pattern_size parameter (%d)\n", max_pattern_size));
    pat = _pattern;
    pat_size = _pattern_size;
    current_bit = 0;
    late = 0;
  end
endtask


endmodule
