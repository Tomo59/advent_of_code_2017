
// this define is used to indent corresponding to "time ns >"
//  so it can be used like "%s some line", `SIGM_INDENT
`define SIGM_INDENT "                      "

`define SIGM_ASSERT(c, X)               \
  if (!(c)) begin                       \
    $fwrite(log.info, "%t > ", $realtime, `C_ERROR, "ERROR", `C_NEUTRAL, " in %m (", `__FILE__, " +" , $psprintf("%0d",`__LINE__), "):\n", `SIGM_INDENT, " ", $psprintf X );       \
     $write(          "%t > ", $realtime, `C_ERROR, "ERROR", `C_NEUTRAL, " in %m (", `__FILE__, " +" , $psprintf("%0d",`__LINE__), "):\n", `SIGM_INDENT, " ", $psprintf X );       \
    bench_main.report_error (8'd 1);    \
    -> bench_main.stop_simulation;      \
  end

// log info

`define SIGM_WARN       (1 << 15)
`define SIGM_NOTICE     (1 << 14)       // important message to notify
`define SIGM_INFO       (1 << 13)       // information
`define SIGM_DBG        (1 << 12)

`define SIGM_ALL        (16'h ffff)

// Those are used to set log level from defparam so it propagates to lower modules
// Currently, we choose to always display WARN, this can be changed in future
`define SIGM_SET_FILE_LOG_LEVEL(level)   ((`SIGM_WARN | ((level) & 32'h ffff)) | (`SIGM_WARN << 16))
`define SIGM_SET_STDOUT_LOG_LEVEL(level) (((`SIGM_WARN | ((level) & 32'h ffff)) << 16) | `SIGM_WARN)

// by default, we want NOTICE on stdout. NOTICE and INFO in the file
`define SIGM_DEFAULT_LOG_LEVEL (`SIGM_SET_FILE_LOG_LEVEL(`SIGM_INFO | `SIGM_NOTICE) | `SIGM_SET_STDOUT_LOG_LEVEL(`SIGM_NOTICE))

`define SIGM_PRINT(verbose, X) begin                            \
  if (verbose == `SIGM_WARN) begin                              \
    $fwrite(log.info, "%t > ", $realtime, `C_WARNING, "WARNING", `C_NEUTRAL, " in %m :\n", `SIGM_INDENT, " ", $psprintf X );   \
     $write(          "%t > ", $realtime, `C_WARNING, "WARNING", `C_NEUTRAL, " in %m :\n", `SIGM_INDENT, " ", $psprintf X );   \
  end else begin                                                \
  if (log.write_in_file & verbose)                              \
    $fwrite(log.info, "%t > ", $realtime, $psprintf X );        \
  if (log.write_in_stdout & verbose )                           \
    $write (          "%t > ", $realtime, $psprintf X );        \
  end end

`define SIGM_PRINT_CONT(verbose, X) begin                       \
  if (log.write_in_file & verbose)                              \
    $fwrite(log.info, $psprintf X );                            \
  if (log.write_in_stdout & verbose)                            \
    $write (          $psprintf X );                            \
  end

`define SIGM_BANNER(verbose, X) begin                                                                            \
  if (log.write_in_file & verbose) begin                                                                         \
    $fwrite(log.info, "\n\n********************************************************************************\n"); \
    $fwrite(log.info, "%t > ", $realtime, $psprintf X );                                                         \
    $fwrite(log.info, "********************************************************************************\n\n");   \
  end if (log.write_in_stdout & verbose) begin                                                                   \
    $write (          "\n\n********************************************************************************\n"); \
    $write (          "%t > ", $realtime, $psprintf X );                                                         \
    $write (          "********************************************************************************\n\n");   \
  end end                                                                                                        \

`define SIGM_MODULE_DESC(_module_desc) begin \
static reg [1024*16*8-1:0] _path = ""; \
$swrite(_path, "%m"); \
`SIGM_PRINT_CFG.declare_module_description(_module_desc, _path); \
end \

