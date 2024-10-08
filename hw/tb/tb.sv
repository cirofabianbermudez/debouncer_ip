`timescale 1ns / 100ps

module tb;

  // Clock signal
  parameter time ClkPeriod = 10ns;
  logic clk_i = 0;
  always #(ClkPeriod / 2) clk_i = ~clk_i;

  // Interface
  debouncer_if vif (clk_i);

  // Test
  test top_test (vif);

  // Instantiation
  debouncer #(
      .ClkFreq(100_000_000),
      .StableTime(1)
  ) dut (
      .clk_i(vif.clk_i),
      .rst_i(vif.rst_i),
      .sw_i(vif.sw_i),
      .db_level_o(vif.db_level_o),
      .db_tick_o(vif.db_tick_o)
  );

  initial begin
    $timeformat(-9, 1, "ns", 10);
    //$fsdbDumpvars;                // Synopsys VCS
  end

endmodule
