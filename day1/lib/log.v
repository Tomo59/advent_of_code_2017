/****h* tango/log
 *
 * NAME
 *   log
 * USED BY
 *   tango bench files
 * HISTORY
 *   11/17/2003 Verilog 2001 fileio update
 * AUTHOR
 *   Guillaume Etorre mailto:guillaume_etorre@realmagic.fr
 * DESCRIPTION
 *   This modules provides a log mechanism for bench files
 *   It uses a verilog "mcd" (multi-channel file descriptor)
 *   This allows to write to multiple files at the same time
 * SOURCE
 */

module log;

   parameter log_level = 0;
   reg [2047:0] module_name;

   localparam LOG_CNT = 16;

   reg [LOG_CNT-1:0] write_in_file;
   reg [LOG_CNT-1:0] write_in_stdout;

   integer   log_file;
   integer   error, warning, info;
   integer   ready;
   
   initial
   begin
     // if (log_level == 0)
     // begin
     //  $write("ERROR : %m.log_level=0\n\tmake sure to propagate log_level in instance\n\tand to set log_level at top\n\n");
     //  $stop;
     // end
   `ifndef DISABLE_FILE_LOG
     if (log_level >= 32'h 100) // new way of using log level : don't use MCD
     begin
       open_non_mcd_log_file;
       // log.error and log.warning go on stsdout
       error = 1;
       warning = 1;
       info = log_file;
 
       write_in_stdout = log_level[31:16] | `SIGM_WARN;
       write_in_file = log_level[15:0] | `SIGM_WARN;
       if ($test$plusargs("max_verbose"))
         write_in_file = `SIGM_ALL;
     end
     else
     begin
       // FIXME shall be removed when all logs are converted to new interface
       if (log_level == 6)
       begin
         // WARNING and ERROR with new mechanism will be printed twice on screen
         open_mcd_log_file;
         error = 1 | log_file;
         warning = 1 | log_file;
         info = 1 | log_file;

         write_in_stdout = 0;
         write_in_file = `SIGM_ALL; // writing in file will also write in stdout
       end
       else
       begin // act like log_level=8
         open_non_mcd_log_file;
         error = 1;
         warning = 1;
         info = log_file;
         write_in_stdout = `SIGM_WARN | `SIGM_NOTICE;
         write_in_file = `SIGM_ALL;
       end
     end
    `else
       error = 1;
       warning = 1;
       info = 1;
       write_in_file   = 0;
       write_in_stdout = `SIGM_WARN | `SIGM_NOTICE;
     `endif
     ready = 1;
   end

  // those can be used to change verbosity at run time from TCL interface or
  // within bench
  function void quiet;
    write_in_stdout = `SIGM_WARN;
  endfunction

  function void verbose;
    write_in_stdout = `SIGM_ALL;
  endfunction

  function void log_enable(input [LOG_CNT-1:0] file = 0, input [LOG_CNT-1:0] stdout = 0);
    begin
      write_in_stdout = write_in_stdout | stdout;
      write_in_file   = write_in_file   | file;
    end
  endfunction

  function void log_disable(input [LOG_CNT-1:0] file = 0, input [LOG_CNT-1:0] stdout = 0);
    begin
      write_in_stdout = write_in_stdout & ~stdout;
      write_in_file   = write_in_file   & ~file;
    end
  endfunction


   task open_mcd_log_file;
      begin
         $swrite(module_name, "%m");
         module_name = truncate_cell(truncate_top(module_name));
         log_file = $fopen({"output/", module_name});
         if(log_file == 0)
           begin
              $fwrite(3, "%t > Closing file to open output/%0s (please adjust log_level parameters)\n", $time, module_name);
              $fclose(2);
              log_file = $fopen({"output/", module_name});
              if(log_file == 0)
                begin
                   $write("Error!    Can't open output/%0s (maybe 'output' directory is missing)\n\n", module_name);
                   $finish;
                end
              $finish;
           end
      end
   endtask // open_mcd_log_file
   
   task open_non_mcd_log_file;
      begin
         $swrite(module_name, "%m");
         module_name = truncate_cell(truncate_top(module_name));
         log_file = $fopen({"output/", module_name}, "w");
         if(log_file == 0)
           begin
              $write("Error!    Can't open output/%0s (maybe 'output' directory is missing)\n\n", module_name);
              $finish;
           end
      end
   endtask // open_non_mcd_log_file
   
   function [2047:0] truncate_top;
      input [2047:0] file_name;
      begin
         truncate_top = file_name;
         while (truncate_top[2047:2040] !== ".")
           begin
              truncate_top = truncate_top << 8;
              if(truncate_top === 2048'b 0)
                // if log is at top-level, truncate_top returns file_name
                truncate_top = {".", file_name};
           end
         // remove the leading "."
         truncate_top = truncate_top << 8;         
      end
   endfunction // truncate_top
  
   function [2047:0] truncate_cell;
      input [2047:0] file_name;
      begin
         truncate_cell = file_name;
         while (truncate_cell[7:0] !== ".")
           begin
              truncate_cell = truncate_cell >> 8;
              if(truncate_cell === 2048'b 0)
                // if log is at top-level, truncate_cell returns file_name
                truncate_cell = {file_name, "."};
           end
         // remove the trailing "."
         truncate_cell = truncate_cell >> 8;         
      end
   endfunction // truncate_cell
  
endmodule // log

