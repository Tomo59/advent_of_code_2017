/*
 * Escape sequences are defined in order to use colors in text display.
 * Drawbacks : control sequences are also present in the log file.
 * It can be removed by a perl -p -e 's/.\[.*?m//g'
 * 
 * 
 * see man 4 console_codes for a complete list of escape sequences
 */


`ifndef SIM_DONT_USE_TEXT_COLORS


`define C_NEUTRAL       "\033[0m"

`define C_RED           "\033[1;31m"
`define C_GREEN         "\033[1;32m"
`define C_YELLOW        "\033[1;33m"
`define C_BLUE          "\033[1;34m"
`define C_PURPULE       "\033[1;35m"
`define C_CYAN          "\033[1;36m"

`define C_ERROR         "\033[1;41;37m" // white on red
`define C_WARNING       "\033[1;4;31m"  // red underline
`define C_INFO1         "\033[1;35m"    // purple
`define C_INFO2         "\033[1;32m"    // green
`define C_INFO3         "\033[1;36m"    // blue

// these escape sequences can change the XTERM title
`define C_X_TITLE_BEGIN "\033]0;"       // begin xterm title
`define C_X_TITLE_END   "\007"          // end xterm title

`else

`define C_NEUTRAL       ""

`define C_RED           ""
`define C_GREEN         ""
`define C_YELLOW        ""
`define C_BLUE          ""
`define C_PURPULE       ""
`define C_CYAN          ""

`define C_ERROR         ""
`define C_WARNING       ""
`define C_INFO1         ""
`define C_INFO2         ""
`define C_INFO3         ""

`define C_X_TITLE_BEGIN ""
`define C_X_TITLE_END   ""

`endif

/***/
