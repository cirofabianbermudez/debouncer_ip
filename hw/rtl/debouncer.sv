///////////////////////////////////////////////////////////////////////////////////
// [Filename]       debouncer.sv
// [Project]        debouncer_ip
// [Author]         Ciro Bermudez
// [Language]       SystemVerilog 2017 [IEEE Std. 1800-2017]
// [Created]        2024.06.22
// [Description]    Debouncer circuit
// [Notes]          Tick output is useful to test FSMs
//                  Level output emulates a Schmitt trigger
//                  ClkFreq:    is the FPGA frequency
//                  StableTime: is the waiting time in ms
//                  Example:
//                    ClkFreq    = 100_000_000    ->   100 MHz
//                    StableTime =          10    ->    10 ms
//                  Then:
//                    CounterMax   = ClkFreq*StableTime/1000 = 1_000_000
//                    CounterWidth = $clog2(CounterMax) = 20
//                  To increase the precision it is possible to change
//                  from ms to us or even to ns but you must adjust the
//                  division factor accordingly.
// [Status]         Stable
///////////////////////////////////////////////////////////////////////////////////

module debouncer #(
    parameter int ClkFreq    = 100_000_000,
    parameter int StableTime = 10
) (
    input  logic clk_i,
    input  logic rst_i,
    input  logic sw_i,
    output logic db_level_o,
    output logic db_tick_o
);

  // Internal variables
  logic ff1, ff2, ff3, ff4;
  logic ena_cnt, clear_cnt;

  // Run the button through two flip-flops to avoid metastability issues
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff1 <= 'd0;
      ff2 <= 'd0;
    end else begin
      ff1 <= sw_i;
      ff2 <= ff1;
    end
  end

  assign clear_cnt = ff1 ^ ff2;

  localparam int CounterMax = ClkFreq * StableTime / 1_000_000;
  localparam int CounterWidth = $clog2(CounterMax);
  logic [CounterWidth-1:0] cnt;

  // Counter logic
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      cnt <= 'd0;
    end else begin
      if (clear_cnt) begin
        cnt <= 'd0;
      end else if (~ena_cnt) begin
        cnt <= cnt + 1'b1;
      end
    end
  end

  assign ena_cnt = (cnt == CounterMax[CounterWidth-1:0] - 1) ? 1'b1 : 1'b0;

  // Output debounce level
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff3 <= 'd0;
    end else if (ena_cnt) begin
      ff3 <= ff2;
    end
  end

  assign db_level_o = ff3;

  // Output single tick with edge detector
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff4 <= 'd0;
    end else if (ena_cnt) begin
      ff4 <= ~ff3 & ff2;
    end
  end

  assign db_tick_o = ff4;

endmodule
