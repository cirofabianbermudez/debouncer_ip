interface debouncer_if(
  input logic clk
);

  logic rst;
  logic sw_i;
  logic db_level_o;
  logic db_tick_o;

  clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output rst;
    output sw_i;
    input  db_level_o;
    input  db_tick_o;
  endclocking

  modport dvr (clocking cb, output rst);

endinterface: debouncer_if
