interface debouncer_if (
    input logic clk_i
);

  logic rst_i;
  logic sw_i;
  logic db_level_o;
  logic db_tick_o;

  clocking cb @(posedge clk_i);
    default input #1ns output #5ns;
    output rst_i;
    output sw_i;
    input db_level_o;
    input db_tick_o;
  endclocking

  modport dvr(clocking cb, output rst_i, output sw_i);

endinterface : debouncer_if
