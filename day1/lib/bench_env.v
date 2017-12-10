/****h* tango/bench_env
 *
 * NAME
 *   bench_env
 * USED BY
 *   read_data
 *   any other bench files
 * HISTORY
 *   27/02/2004 - initial version
 * AUTHOR
 *   Mario Trentini mailto:mario_trentini@realmagic.fr
 * DESCRIPTION
 *   This module provides a environment to save the evolution of state variables
 *
 *   Interface :
 *     * parameter max_variable : number of maximum different variables in the
 *       environment
 *     * function update (name, value)
 *       name=value, name is a string describing the variable
 *     * function value (name)
 *       return the value of the variable name
 *     * task print (f)
 *       print the name and the value of the variables in the environement
 *       f is the file descriptor to write
 *     * function parse (string)
 *       parse string to feed the environment using format :
 *       name=value
 *
 * SOURCE
 */


// TODO : define or parameter ?
`define SIZE_VARIABLE_NAME      256

module bench_env ();

  parameter max_variable = 8;
  parameter BUFFER_SIZE  = 16384;
  parameter force_enable = 0;


  reg [`SIZE_VARIABLE_NAME - 1:0]       variable_name[0:max_variable - 1];
`ifdef VALUE_ARE_NUMERIC
  integer                               variable_data[0:max_variable - 1];
`else
  reg [`SIZE_VARIABLE_NAME - 1:0]       variable_data[0:max_variable - 1];
`endif
  integer                               nr_variable_used;

  reg[`SIZE_VARIABLE_NAME * max_variable * 2:0] environment_description;

  function update_description;
      input     dummy;
      integer   i;
    begin
      environment_description = "";
      for (i = 0; i < nr_variable_used; i = i + 1)
        $swrite (environment_description, "%0s\n%0s=%0s",
                 environment_description, variable_name[i], variable_data[i]);
    end
  endfunction

  initial
    nr_variable_used = 0;

  function update;
      input reg [`SIZE_VARIABLE_NAME - 1:0]     name;
`ifdef VALUE_ARE_NUMERIC
      input integer                             value;
`else
      input reg [`SIZE_VARIABLE_NAME - 1:0]     value;
`endif
      integer                                   i;
      integer                                   found;
    begin
      found = 0;
      for (i = 0; i < nr_variable_used && !found; i = i + 1)
        if (variable_name[i] == name)
          begin
            variable_data[i] = value;
            found = 1;
          end
      if (! found && nr_variable_used < max_variable)
        begin
          variable_name[nr_variable_used] = name;
          variable_data[nr_variable_used] = value;
          nr_variable_used = nr_variable_used + 1;
        end
      i = update_description (0);
    end
  endfunction

`ifdef VALUE_ARE_NUMERIC
    function integer value;
`else
    function [`SIZE_VARIABLE_NAME - 1:0] value;
`endif
      input reg [`SIZE_VARIABLE_NAME - 1:0]     name;
      integer                                   i;
      integer                                   found;
    begin
      found = 0;
      for (i = 0; i < nr_variable_used && !found; i = i + 1)
        if (variable_name[i] == name)
          begin
            value = variable_data[i];
            found = 1;
          end
    end
  endfunction

  task print;
      input integer     f;
      integer           i;
    begin
      $fwrite (f, "%t > ", $realtime, `C_INFO3, "%0d", nr_variable_used, 
               `C_NEUTRAL, " / ", `C_INFO3, "%0d", max_variable,
               `C_NEUTRAL, " variable(s) in the state environment\n");
      for (i = 0; i < nr_variable_used; i = i + 1)
        $fwrite (f, `C_INFO2, "%0s", variable_name[i], `C_NEUTRAL, "\t=>\t",
`ifdef VALUE_ARE_NUMERIC
                 `C_INFO1, "%0d",
`else
                 `C_INFO1, "%0s",
`endif
                 variable_data[i], `C_NEUTRAL, "\n");
    end
  endtask

  /*
   * TODO
   * Parsing is a little bit ugly and might slow down too much
   * improvment can be done here...
   */
  function parse;
      input reg [BUFFER_SIZE-1:0]               text;
      reg [`SIZE_VARIABLE_NAME - 1:0]           name;
      reg [BUFFER_SIZE-1:0]                     buffer1, buffer2;
`ifdef VALUE_ARE_NUMERIC
      integer                                   value;
`else
      reg [`SIZE_VARIABLE_NAME - 1:0]           value;
`endif
      integer                                   i;
      integer                                   j;
    begin
      if (!(force_enable != 0 ||
           $test$plusargs("enable_bench_env") ||
           $test$plusargs("max_verbose")))
        return 0;
      i = 1;
      buffer2 = text;
      while (i)
        begin
          // go to next space
          while (buffer2[BUFFER_SIZE-1-:8] != " " && buffer2[BUFFER_SIZE-1-:8] != "")
            buffer2 = buffer2 << 8;
          j = $sscanf (buffer2, "%s", buffer1); 
          if (j == 1)
            begin
              // find =
              while (buffer1[2047:2040] == "")
                buffer1 = buffer1 << 8;
              while (buffer1[2047:2040] != "" &&
                     buffer1[2047:2040] != "=")
                buffer1 = buffer1 << 8;
              if (buffer1[2047:2040] == "=")
                begin
                  buffer1[2047:2040] = " ";
`ifdef VALUE_ARE_NUMERIC
                  j = $sscanf (buffer1, "%s %d", name, value);
`else
                  j = $sscanf (buffer1, "%s %s", name, value);
`endif
                  if (j == 2)
                    j = update (name, value);
                end
              // go to next word
              while (buffer2[BUFFER_SIZE-1-:8] == " ")
                buffer2 = buffer2 << 8;
            end
          else
            i = 0;
        end
    end
  endfunction

`undef SIZE_VARIABLE_NAME

endmodule


/***/
