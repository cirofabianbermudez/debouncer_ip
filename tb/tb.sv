`timescale 1ns/100ps

module tb;
  
  // 100 MHz signal
  logic clk_i = 0;
  always #5 clk_i = ~clk_i;

  // Interface
  debouncer_if vif(clk_i);
  
  test top_test(vif);
 
  // Instantiation
  debouncer #(
    .ClkRate(10_000_000),
    .Baud(1_000_000)
  ) dut (
    .clk_i(vif.clk_i),
    .rst_i(vif.rst_i),
    .sw_i(vif.sw_i),
    .db_level_o(vif.db_level_o),
    .db_tick_o(vif.db_tick_o)
  );

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end

endmodule