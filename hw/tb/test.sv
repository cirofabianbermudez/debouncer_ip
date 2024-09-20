module test (
    debouncer_if.dvr db_if
);

  int debounce_time;

  initial begin
    $display("Begin Of Simulation.");
    debounce_time = 120;
    reset();
    normal();
    bounce();
    $display("End Of Simulation.");
    $finish;
  end

  task automatic reset();
    db_if.rst_i = 1'b1;
    db_if.sw_i  = 1'b0;
    repeat (2) @(db_if.cb);
    db_if.cb.rst_i <= 1'b0;
    repeat (debounce_time) @(db_if.cb);
  endtask : reset

  task automatic normal();
    db_if.cb.sw_i <= 1'b1;
    repeat (debounce_time) @(db_if.cb);
    db_if.cb.sw_i <= 1'b0;
    repeat (debounce_time) @(db_if.cb);
  endtask : normal

  task automatic bounce();
    int delay1, delay2;
    realtime time1, time2;
    for (int i = 0; i < 1000; i++) begin
      db_if.cb.sw_i <= 1'b1;
      time1  = $realtime;
      delay1 = $urandom_range(debounce_time / 2, debounce_time);
      repeat (delay1) @(db_if.cb);
      db_if.cb.sw_i <= 1'b0;
      delay2 = $urandom_range(debounce_time / 2, debounce_time);
      time2  = $realtime;
      repeat (delay2) @(db_if.cb);
      $display("iter = %3d, delay1 = %3d, delay2 = %3d, time1 = %t, time2 = %t", i, delay1, delay2,
               time1, time2);
    end
  endtask : bounce

endmodule : test
