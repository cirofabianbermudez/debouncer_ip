module debouncer #(
  parameter ClkRate = 10_000_000,
  parameter Baud = 10_000
) (
  input  logic clk_i,
  input  logic rst_i,
  input  logic sw_i,
  output logic db_level_o,
  output logic db_tick_o
);
  
  // Internal variables
  logic ff1, ff2, ff3, ff4;
  logic ena_cnt, clr_cnt;

  // Run the button through two flip-flops to avoid metastability issues
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff1 <= 0;
      ff2 <= 0;
    end else begin
      ff1 <= sw_i;
      ff2 <= ff1;
    end
  end

  assign clr_cnt = ff1 ^ ff2;

  localparam BaudCounterMax = ClkRate/Baud;
  localparam BaudCounterSize = $clog2(BaudCounterMax);
  logic [BaudCounterSize-1:0] cnt;

  // Counter logic
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      cnt <= '0;
    end else begin
      if (clr_cnt) begin
        cnt <= '0;
      end else if (~ena_cnt) begin
        cnt <= cnt + 1'b1;
      end
    end
  end 

  assign ena_cnt = (cnt == BaudCounterMax-1) ? 1'b1 : 1'b0;

  // Output debounce level
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff3 <= 0;
    end else if(ena_cnt) begin
      ff3 <= ff2;
    end
  end

  assign db_level_o = ff3;
  
  // Output single tick with edge detector
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      ff4 <= 0;
    end else if (ena_cnt) begin
      ff4 <= ~ff3 & ff2;
    end
  end
  
  assign db_tick_o = ff4;
  
endmodule
