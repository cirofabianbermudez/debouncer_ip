module test (
    debouncer_if.dvr db_if
);

  initial begin
    $display("Begin Of Simulation.");
    reset();
    normal();
    bounce();
    $display("End Of Simulation.");
    $finish;
  end

  task reset();
    db_if.rst_i = 1'b1;
    db_if.sw_i  = 1'b0;
    repeat (2) @(db_if.cb);
    db_if.cb.rst_i <= 1'b0;
    repeat (12) @(db_if.cb);
  endtask : reset

  task normal();
    db_if.cb.sw_i <= 1'b1;
    repeat (30) @(db_if.cb);
    db_if.cb.sw_i <= 1'b0;
    repeat (30) @(db_if.cb);
  endtask : normal

  task bounce();
    int delay1, delay2;
    realtime time1, time2;
    for (int i = 0; i < 50; i++) begin
      db_if.cb.sw_i <= 1'b1;
      time1  = $realtime;
      delay1 = $urandom_range(1, 15);
      repeat (delay1) @(db_if.cb);
      db_if.cb.sw_i <= 1'b0;
      delay2 = $urandom_range(1, 15);
      time2  = $realtime;
      repeat (delay2) @(db_if.cb);
      $display("iter = %3d, delay1 = %3d, delay2 = %3d, time1 = %t, time2 = %t", i, delay1, delay2, time1, time2);
    end
  endtask : bounce

endmodule : test
