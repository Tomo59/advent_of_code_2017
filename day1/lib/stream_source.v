/****h* tango/stream_source
 *
 * NAME
 *   stream_source
 * USED
 *   read_data
 *   random_control
 *   rate_counter
 * USED BY
 *   bench files
 * HISTORY
 *   17/03/2004 - new version using submodule functions
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@realmagic.fr
 * DESCRIPTION
 *   This module reads data from a file for output
 *
 *   The data in the file can be in hexa, binary or ascii
 *   The file must follow the format of one data for each line.
 *   Line beginning with # are comments
 *   The first word of the line is the data
 *
 *   On rdy the next data in the file is read and put in the output.
 *
 *   Usefull signals in the designs are :
 *     read_data.*      : for file positions and information
 *
 *   Tasks
 *     open (filename)           : open a new file for reading
 *     start (count)             : start sending data and stop after <count> data (0 means unlimited)
 *     start_until_label (label, match_type) : start sending data and stop at label <label>
 *                                     * match_type == 1 => strict matching (strcmp)
 *                                     * match_type == 2 => glob matching (strstr)
 *                                     * match_type == 3 => regular expression matching (regex)
 *     stop
 *     random_control.* : change random behavior
 *
 *   Input file
 *     if parameter filename is set to "counter" output data come from a counter.
 *     if parameter filename is set to "random" output data are random.
 *     if parameter filename is set to "ext" output data is constant = 0
 *     else filename should be an input file name
 * SOURCE
 */


module stream_source (data, vld, rdy, clk);

//-------------- Interface -----------------------

  parameter data_width          = 1;
  parameter P_CNT               = 1;
  parameter mem_size            = 0;    // unused : kept for compability with
                                        // previous version
  parameter filename            = "counter";
  parameter data_type           = "ascii_hex";
  parameter log_level           = 2;
  parameter rate_window_size    = 64;
  parameter random_invalid_data = 0;

  input                                 clk;
  input                                 rdy;
  output [P_CNT-1:0]                    vld;
  output reg [data_width*P_CNT-1:0]     data;

  // present for backward compability with previous version
  wire                          eof;
  event                         eof_event;

//-------------- Internal variables --------------

  wire                          running;
  wire                          vld_ctrl;
  bit [P_CNT-1:0]               vld_bits;
  integer                       forced_bits_vld; // if != 0, nb bits forced to valid
  reg [data_width-1:0]          file_data;
  bit                           use_file;
  reg                           stop_called;
  integer                       counter;
  integer                       total_size;
  integer                       stop_in_count_transaction;
  integer                       line_size;
  integer                       cut_in_count_transaction;
  reg [data_width-1:0]          random_value;
  reg [2047:0]                  cur_file_name;      // file name actually used
  reg [2047:0]                  instance_name;

  wire [data_width - 1:0]       data_dummy;

  read_data #(
    .data_width                 (data_width),
    .filename                   (""),
    .data_type                  (data_type),
    .watch_level                (1)
    )
    read_data (
      .clk                      (clk),
      .rdy                      (1'b0),
      .data                     (data_dummy)
    );

  random_control #(
    .random_behavior            (1)
    )
    random_control (
      .clk                      (clk),
      .control_in               (rdy),
      .control_out              (vld_ctrl)
    );

  rate_counter #(
    .window_size                (rate_window_size)
    )
    rate_counter (
      .clk                      (clk),
      .rdy                      (rdy),
      .vld                      (vld_ctrl)
  );

  assign eof = read_data.eof;

  always @(read_data.eof_event)
    -> eof_event;

  reg  [P_CNT*data_width-1:0] data_real;
  reg  [P_CNT*data_width-1:0] random_data;

  assign vld = {P_CNT{vld_ctrl}} & vld_bits;
  assign running = (read_data.running | (|vld_bits) | ~use_file) && random_control.running;
  assign data = (|vld === 1'b1) ? data_real : random_invalid_data ? random_data : {P_CNT*data_width{1'bx}};

  initial
    begin
      use_file = 0;
      stop_called = 0;
      counter = 0;
      line_size = 0;
      $swrite (instance_name, "%m");
      instance_name = truncate (instance_name);
      cur_file_name = filename;
      forced_bits_vld = 0;
      total_size = 0;
    end

task automatic start_random_control_delayed(input int count);
fork
begin
  #0.1;
  random_control.start(count);
end
join_none
endtask

task automatic prepare_next_data_and_valid(input bit update_values);
  int             i;
  bit [P_CNT-1:0] vld_tmp;
  bit             data_already_output;
  int unsigned    nb_vld;

  if (stop_called)
    nb_vld = 0;
  else
  begin
    if (forced_bits_vld != 0)
      nb_vld = forced_bits_vld;
    else if (random_control.current_rate == 100)
      // FIXME: this is only a workaround, rate should be applied on each bit
      nb_vld = P_CNT;
    else
      // FIXME: this is not correct at all since bitrate will be far under asked rate
      nb_vld = $urandom_range(1,P_CNT);

    // Limit nb_vld based on line_size
    if ((line_size > 0) && (nb_vld > cut_in_count_transaction))
      nb_vld = cut_in_count_transaction;
    // Limit nb_vld total_size
    if ((total_size > 0) && (nb_vld > stop_in_count_transaction))
      nb_vld = stop_in_count_transaction;

    // deal with count if we do not have infinite total_size and line_size
    if (line_size > 0)
    begin
      cut_in_count_transaction -= nb_vld;
      if (cut_in_count_transaction == 0)
        cut_in_count_transaction = line_size;
    end
    if (total_size > 0)
    begin
      stop_in_count_transaction -= nb_vld;
      if (stop_in_count_transaction == 0)
      begin
        stop_called = 1;
        // allow only one more data
        start_random_control_delayed(1);
      end
    end
  end

  // set vld to trunc value
  vld_tmp = (1 << nb_vld) - 1;
  data_already_output = 0;
  for (i=0; i<P_CNT; i++)
  begin
    if (vld_tmp[i] == 1'b1)
    begin
      data_real[i*data_width+:data_width] <= current_data(update_values || data_already_output); // force to update value for all but first one
      data_already_output = 1;
      if (use_file && (read_data.current_data_vld == 0))
        vld_tmp[i] = 0;
    end
    else
      data_real[i*data_width+:data_width] <= random_invalid_data ? random_data : {data_width{1'bx}};
  end

  // if no data valid at all, it means we are stopped. Read one data in read_data for next time
  if (|vld_tmp == 1'b0 && use_file)
    file_data = ~(~read_data.next_data (0));

  vld_bits <= vld_tmp;
endtask // prepare_next_data_and_valid

always @(posedge clk)
begin
  if (rdy & |vld)
    prepare_next_data_and_valid(1);
end

always @(posedge clk)
begin
  int i;
  for (i=0; i<P_CNT; i++)
  begin
    // random_data is used to maximise toggling
    if (vld[i] == 1)
      random_data[i*data_width+:data_width] <= ~data[i*data_width+:data_width];
    else
      random_data[i*data_width+:data_width] <= ~random_data[i*data_width+:data_width];
  end
end

  function [data_width-1:0] current_data(input bit update_values);
    begin
      if (cur_file_name == "counter")
      begin
        if (update_values)
          counter = counter + 1;
        return counter;
      end

      if (cur_file_name == "random")
      begin
        int i, tmp;
        current_data = 0;
        for (i=0; i<(data_width+31)/32; i++)
        begin
          tmp = $urandom;
          current_data |= tmp << (32*i);
        end
        return current_data;
      end

      if (use_file)
      begin
        // file_data is double neg to transform z => x
        if (update_values)
          file_data = ~(~read_data.next_data (0));
        else
          file_data = ~(~read_data.get_current_data(0));
        return file_data;
      end

      // default return 0 (normally, cur_file_name should be "ext"
      //if (cur_file_name == "ext")
      return 0;
    end
  endfunction

  always @(random_control.running)
  begin
    if (random_control.running == 0)
      stop_called = 1;
  end


  // remove the first word
  function [2047:0] truncate;
      input [2047:0] file_name;
    begin
      truncate = file_name;
      while (truncate[2047:2040] !== ".")
        begin
          truncate = truncate << 8;
          if (truncate === 2048'b 0)
            // if at top-level, truncate returns file_name
            truncate = {".", file_name[2040:0]};
        end
      // remove the leading "."
      truncate = truncate << 8;
    end
  endfunction

//************** Start,Stop  tasks *******************

  task open;
      input reg [2047:0] name;
    begin
      if (name == "auto")
      begin
        cur_file_name = {"output/input/", instance_name[2047:13*8]};
      end
      else
        cur_file_name = name;

      if (cur_file_name == "counter" || cur_file_name == "ext" || cur_file_name == "random")
      begin
        use_file = 0;
        read_data.file_name = cur_file_name;
      end
      else
      begin
        if (read_data.file_name != cur_file_name)
        begin
          if (read_data.open (cur_file_name))
            use_file = 1;
          else
          begin
            use_file = 0;
            $fwrite(log.error, "%t > Error : %m opening file %0s failed\n",
                    $realtime, cur_file_name);
            $stop;
          end
        end
      end
    end
  endtask

  task start
    (
      input integer     count,
      input integer     _line_size = 0
    );
    begin
      #0.01;
      if (running)
        $fwrite (log.warning, "%t > Warning: %m called but source is already running\n", $realtime);
      else
        begin
          open(cur_file_name);
          read_data.start;
          random_control.start(0);
          stop_called = 0;
          total_size = count;
          stop_in_count_transaction = count;
          line_size = _line_size;
          cut_in_count_transaction = _line_size;
          prepare_next_data_and_valid(0);
        end
    end
  endtask

  task start_until_label
    (
      input [2047:0]    label,
      input integer     match_type = 1,
      input integer     _line_size = 0,
      input integer     count = 0
    );
    begin
      #0.01;
      if (running)
        $fwrite (log.warning, "%t > Warning: %m called but source is already running\n", $realtime);
      else
        begin
          open(cur_file_name);
          read_data.read_until_label (label, match_type);
          random_control.start(0);
          stop_called = 0;
          total_size = count;
          stop_in_count_transaction = count;
          line_size = _line_size;
          cut_in_count_transaction = _line_size;
          prepare_next_data_and_valid(0);
        end
    end
  endtask

  task jump_to_label
    (
      input reg [2047:0]     label,
      input integer          match_type = 1
    );
    begin
      if (running)
        $fwrite (log.warning, "%t > Warning: %m called but source is already running\n", $realtime);
      else
        begin
          open(cur_file_name);
          if (use_file)
            read_data.jump_to_label (label, match_type);
        end
    end
  endtask

  task stop;
    begin
      stop_called = 1;
      random_control.stop;
      read_data.stop;
    end
  endtask


endmodule

/***/
