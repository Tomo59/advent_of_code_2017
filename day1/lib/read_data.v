/****h* tango/read_data
 *
 * NAME
 *   read_data
 * USED BY
 *   bench files
 * USES
 *   bench_env
 * HISTORY
 *   17/03/2004 - initial version
 *   12/01/2005 - add binary format
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@realmagic.fr
 *   Guillaume Etorre mailto:guillaume_etorre@realmagic.fr
 * DESCRIPTION
 *   This module reads and parses a file for data
 *
 *   The data in the file can be in hexa, binary or ascii
 *   The file must follow the format of one data for each line.
 *   Line beginning with # are comments
 *   The first word of the line is the data
 *   In binary mode, data width must be a multiple of 8. Data
 *   is read in network order. Labels are not supported.
 *
 *   On rdy the next data in the file is read and put in the output.
 *
 *   Usefull signals in the designs are :
 *     eof              : end of reading file
 *     eof_event        : event triggered at the end of the file
 *     count_line       : number of line in the file
 *     count_data       : number of data
 *     stream_info      : the last comment (#) in the stream
 *
 *   Tasks
 *     open (filename)          : open a new file for reading
 *     jump_to_label (label)    : go to the line 'label'
 *     read_until_label (label) : stop the reading at line 'label'
 *     seek_start_data (n)      : go to the data number n from the beginning of
 *                                the file
 *     save_position            : save the position in the stream file
 *     save_position_value(n)   : save n into the saved position (n corresponds to a data count)
 *     restore_position         : restore the saved position
 *
 * SOURCE
 */


module read_data (clk, rdy, data);

//-------------- Interface -----------------------

  parameter data_width          = 1;
  parameter filename            = "";
  parameter data_type           = "ascii_hex";
  parameter log_level           = 2;
  parameter watch_level         = 2;
  parameter BUFFER_SIZE         = 16384;

  input                         clk;
  input                         rdy;
  output [data_width-1:0]       data;

  reg [data_width-1:0]          data;
  reg                           data_vld;

//-------------- Internal variables --------------

  // _ can exist in ascii version of a value, so range shall be large enough
  localparam buffer_range = data_type == "ascii" ? BUFFER_SIZE : (data_width * 32);

  bench_env #(.BUFFER_SIZE(BUFFER_SIZE)) bench_env ();

  reg                           eof;
  event                         eof_event;
  integer                       count_line;
  integer                       count_data;
  integer                       count_data_max;
  reg [BUFFER_SIZE - 1:0]       stream_info;

  reg [2047:0]                  file_name;      // file name actually used
  integer                       fd;             // fd used of reading
  reg                           running;        // the module is running
  integer                       stop_on_label;  // 1: exact matching
                                                // 2: label shall be contained in the line
                                                // 3: regexp matching
  longint                       regexp_struct = 0;  // pointer to the regexp_structure used in C code
  integer                       saved_position;
  reg [2047:0]                  label;
  integer                       watchlevel;

  integer r;
  initial
    begin
      if ((data_type == "binary") && (data_width % 8))
        begin
           $fwrite (log.error, "%t > Error: %m.data_width must be a multiple of eight bits in binary mode", $realtime);
           $stop;
        end
      eof = 1;
      count_line = 0;
      count_data = 0;
      count_data_max = 0;
      stop_on_label = 0;
      label = "";
      stream_info = "";
      saved_position = 0;
      file_name = filename;
      watchlevel = watch_level;

      if (file_name != "")
        r = open (file_name);
      else
        begin
          running = 0;
          data_vld = 1'b 0;
          fd = 0;
        end

      // TODO : find a way to use SIGM_ASSERT in initial block
      #0;
      `SIGM_ASSERT((data_type == "binary") || (data_type == "ascii_hex") || (data_type == "ascii_bin") || (data_type == "ascii"), ("Unknown data_type parameter : %0s\n", data_type));
    end

  always @(posedge clk)
    if (rdy && running)
      data = next_data (0);

  reg [BUFFER_SIZE - 1: 0]      buffer;
  reg [buffer_range- 1: 0]      buffer_scanf;

  event                         stop_delay_running;
  always @(stop_delay_running)
    data_vld <= 1'b 0;

  reg [data_width - 1 : 0] next_line_data;

  reg [data_width - 1 :0]  current_data;
  reg                      current_data_vld;

  // this function returns the current data
  function [data_width - 1 : 0] get_current_data;
      input                             dummy;
      integer                           r;
    begin
      if (!current_data_vld)
        r = next_data(0);
      get_current_data = current_data;
    end
  endfunction


  // this function reads the next data on the file
  //

  function [data_width - 1 : 0] next_data;
      input                             dummy;
      integer                           r;
      reg [data_width - 1:0]            file_data;
    begin
      if (data_type == "binary")
        begin
           current_data_vld = 0;
           r = $fread(file_data, fd);
           if (r == 0)
             begin
                running = 0;
                -> stop_delay_running;
                eof = 1;
                -> eof_event;
                if (watchlevel >= 1)
                  $fwrite (log.error, "%t > No more data in %0s at data %0d\n",
                           $realtime, file_name, count_data);
             end
           else 
             begin
                next_data = file_data;
                current_data = file_data;
                inc_count_data;
                current_data_vld = 1'b1;
                if (r != (data_width / 8))
                  $fwrite (log.warning, "%t > Truncated data in %0s at data %0d\n",
                           $realtime, file_name, count_data);  
             end
        end
      else
        begin
           r = 0;
           while (!r && running)
             begin
                r = next_line (0);
                if (r)
                begin
                  next_data = next_line_data;
                  current_data = next_line_data;
                end
             end
        end
    end
  endfunction

  function void inc_count_data;
    begin
      count_data = count_data + 1;
      if (count_data > count_data_max)
      begin
        // we trigger the heartbeat each time we read a new line of an input file
        // this should be safe because we shouldn't have infinite file
        count_data_max = count_data;
      end
    end
  endfunction

  function [2047:0] remove_trailing_cr;
      input reg [2047:0]    buf_in;
    begin
      if (buf_in[7:0] == "\n")
        remove_trailing_cr = buf_in[2047:8];
      else
        remove_trailing_cr = buf_in;
    end
  endfunction

import "DPI-C" pure dpi_strstr = function int strstr_c (input string s1, input string s2);
import "DPI-C" context dpi_create_regexp = function longint create_regexp_c (input longint regexp, input string s2);
import "DPI-C" context dpi_match_regexp = function int match_regexp_c (input longint regexp, input string s);

  function integer next_line;
      input                             dummy;
      integer                           r;
    begin
       if (data_type == "binary")
         begin
            $fwrite (log.error,
                     "%t > Unsupported call to next_line task in binary file reader %m\n", $realtime);
            $stop;
         end
       else
         begin
            current_data_vld = 1'b0;
            next_line = 0;
            r = $fgets (buffer, fd);
            count_line = count_line + 1;
            if (r == 0) // no more data
              begin
                 running = 0;
                 -> stop_delay_running;
                 eof = 1;
                 -> eof_event;
                 if (watchlevel >= 1)
                   $fwrite (log.error, "%t > No more data in %0s at line %0d\n",
                            $realtime, file_name, count_line);
              end
            else if (stop_on_label == 1 && label == buffer ||
                     stop_on_label == 2 && strstr_c(buffer, label) ||
                     stop_on_label == 3 && match_regexp_c(regexp_struct, buffer))
              begin
                 running = 0;
                 -> stop_delay_running;
                 stop_on_label = 0;
                 if (buffer[8*(r-1) +: 8] == "#")  begin
                   buffer = buffer << BUFFER_SIZE - 8 * r;
                   if (buffer[BUFFER_SIZE -1: BUFFER_SIZE - 8 * 8] == "# PRINT ")
                     $fwrite(log.warning, "%t > ", $realtime, `C_INFO2, "%0s", buffer[BUFFER_SIZE - 8*8:0], `C_NEUTRAL, "\n");
                    stream_info = buffer;
                    buffer = buffer >> BUFFER_SIZE - 8 * r;
                    r = bench_env.parse (stream_info);
                 end
                 if (watchlevel >= 1)
                   $fwrite (log.error, "%t > In ", $realtime, `C_INFO2, "%0s",
                            file_name, `C_NEUTRAL, " reach label \"%0s\" @count_line=%0d\n",
                            remove_trailing_cr(buffer),count_line);
              end
            else
              begin
                 if (buffer[8*(r-1) +: 8] == "#")
                   begin
                     buffer = buffer << BUFFER_SIZE - 8 * r;
                     if (buffer[BUFFER_SIZE -1: BUFFER_SIZE - 8 * 8] == "# PRINT ")
                       $fwrite(log.warning, "%t > ", $realtime, `C_INFO2, "%0s", buffer[BUFFER_SIZE - 8*8:0], `C_NEUTRAL, "\n");
                      stream_info = buffer;
                      buffer = buffer >> BUFFER_SIZE - 8 * r;
                      r = bench_env.parse (stream_info);
                   end
                 else
                   begin
                     // for speed consideration, do the scanf on a smaller
                     // buffer
                     if (8*r < buffer_range)
                       buffer_scanf = buffer;
                     else
                       buffer_scanf = buffer >> 8*r - buffer_range;
                     buffer = buffer << BUFFER_SIZE - 8 * r;
                      case (data_type)
                        "ascii_hex" :
                          r = $sscanf (buffer_scanf, "%h", next_line_data);
                        "ascii_bin" :
                          r = $sscanf (buffer_scanf, "%b", next_line_data);
                        "ascii" :
                          r = $sscanf (buffer, "%s", next_line_data);
                        default :
                          r = $sscanf (buffer_scanf, "%h", next_line_data);
                      endcase
                      if (r != 0)
                        begin
                           inc_count_data;
                           next_line = 1;
                           current_data_vld = 1'b1;
                        end
                   end
              end
         end
    end
  endfunction

  task jump_to_label
    (
      input reg [BUFFER_SIZE - 1:0]     label,
      input integer                     match_type = 1 // 1 : strict matching (strcmp)
                                                       // 2 : glob matching (strstr)
                                                       // 3 : regular expression matching (regex)
    );
      integer                           r;
      reg                               loop;
    begin
      current_data_vld = 1'b0;
       if (data_type == "binary")
         begin
            $fwrite (log.error,
                     "%t > Unsupported call to jump_to_label task in binary file reader %m\n", $realtime);
            $stop;
         end
       else
         begin
            loop = 1;
            if (!eof)
            begin
              $fwrite (log.error, "%t > In ", $realtime, `C_INFO2, "%0s", file_name,
                       `C_NEUTRAL, " jump from line %0d to label \"%0s\"", count_line,
                       remove_trailing_cr(label));
              if (match_type == 3)
                 regexp_struct = create_regexp_c(regexp_struct, label);

              while (loop && !eof)
                begin
                   r = next_line (0);
                   if (match_type == 1 && label == buffer ||
                       match_type == 2 && strstr_c (buffer, label) ||
                       match_type == 3 && match_regexp_c(regexp_struct, buffer) )
                     loop = 0;
                end
              if (!eof)
                $fwrite (log.error, " at line %0d", count_line);
              $fwrite (log.error, "\n");
            end
         end
    end
  endtask


//************** Start,Stop  tasks *******************

  function integer open;
      input [2047:0] name;
    begin
      // task open put running at 0 so that if we open a new file
      // before the end of the previous file, data will get updated
      running = 0;
      count_line = 0;
      count_data = 0;
      file_name = name;

      if (fd != 0)
        $fclose (fd);
      if (file_name != "")
        fd = $fopen (file_name, "r");
      else
        fd = 0;
      if (fd == 0)
        begin
          if (file_name != "")
            `SIGM_PRINT(`SIGM_WARN, ("Error opening file %0s for reading\n", file_name));
          data_vld = 1'b 0;
          eof = 1;
          open = 0;
        end
      else
        begin
          data_vld = 1'b 1;
          eof = 0;
          open = 1;
        end
      current_data_vld = 1'b0;
    end
  endfunction

  task start;
    begin
      if (!eof)
        begin
          running = 1;
          data_vld <= 1'b 1;
          data = get_current_data(0);
          // Don't touch current_data_vld here: get_current_data will put it to the right state
          // current_data_vld = 1'b1;
        end
    end
  endtask


  task stop;
    begin
      stop_on_label = 0;
    end
  endtask


  task read_until_label
    (
      input [2047:0]    l,
      input integer     match_type = 1 // 1 : strict matching (strcmp)
                                       // 2 : glob matching (strstr)
                                       // 3 : regular expression matching (regex)
    );
    begin
       if (data_type == "binary")
         begin
            $fwrite (log.error,
                     "%t > Unsupported call to read_until_label task in binary file reader %m\n", $realtime);
            $stop;
         end
       else
         begin
            stop_on_label = match_type;
            label = l;
            if (match_type == 3)
               regexp_struct = create_regexp_c(regexp_struct, l);
            start;
         end
    end
  endtask

  task seek_start_data;
      input [31:0]              n;
      integer                   i;
      reg [data_width - 1 : 0]  r;
      integer running_tmp;
    begin
      if (fd != 0)
        begin
          eof = 0;
          $fwrite (log.error, "%t > In ", $realtime, `C_INFO2, "%0s", file_name,
                   `C_NEUTRAL, " jump from data %0d to data %0d\n", count_data,
                   n);
          if ( count_data == n)
            return;
          i = $fseek (fd, 0, 0);
          count_line = 0;
          count_data = 0;
          i = 0;
          running_tmp = running;
          running = 1; // force the pointer to go the correct place 
                       // even if it has been stopped
          while (i < n && !eof)
            begin
              r = next_data (0);
              i = i + 1;
            end
          current_data_vld = 1'b0;
          running = running_tmp;
        end
    end
  endtask

  task seek_start_line;
      input [31:0]              n;
      reg [data_width - 1 : 0]  r;
      integer running_tmp, dummy;
    begin
      if (fd != 0)
      begin
        `SIGM_ASSERT((data_type != "binary"), ("Cannot use seek_start_line in binary mode\n"));

        eof = 0;
        $fwrite (log.error, "%t > In ", $realtime, `C_INFO2, "%0s", file_name,
                 `C_NEUTRAL, " jump from line %0d to line %0d\n", count_line,
                 n);
        if ( count_line == n)
          return;
        dummy = $fseek (fd, 0, 0);
        count_line = 0;
        count_data = 0;
        running_tmp = running;
        running = 1; // force the pointer to go the correct place 
        // even if it has been stopped
        while (count_line < n && !eof)
        begin
          dummy = next_line (0);
        end
        current_data_vld = 1'b0;
        running = running_tmp;
        end
    end
  endtask

  task save_position;
    begin
      if (data_type != "binary")
        saved_position = count_line;
      else
        saved_position = count_data;
      // if we save the position while the read data is still running,
      // it means we saved the next position and when we will restore, it will be one position ahead
      if (saved_position > 0 && current_data_vld)
        saved_position = saved_position - 1;
    end
  endtask

  task restore_position;
    begin
      if (data_type != "binary")
        seek_start_line (saved_position);
      else
        seek_start_data (saved_position);
    end
  endtask

  task set_watch_level;
    input [31:0] value;
    begin
      watchlevel = value;
    end
  endtask

  //final
  //  begin
  //    if (eof)
  //    begin
  //      `SIGM_PRINT(`SIGM_INFO, ("%m has reached end of file\n"));
  //    end
  //    else
  //    begin
  //      `SIGM_PRINT(`SIGM_INFO, ("%m has reached line %d\n", count_line));
  //    end
  //  end

endmodule

/***/
