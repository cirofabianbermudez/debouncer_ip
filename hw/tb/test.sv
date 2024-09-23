module test (
    debouncer_if vif
);

  int debounce_time;

  initial begin
    $display("Begin Of Simulation.");
    debounce_time = 120;
    reset();
    fork

      begin
        normal();
        bounce();
      end

      begin
        check_db_tick();
      end

    join

    $display("End Of Simulation.");
    $finish;
  end

  task automatic reset();
    vif.rst_i = 1'b1;
    vif.sw_i  = 1'b0;
    repeat (2) @(vif.cb);
    vif.cb.rst_i <= 1'b0;
    repeat (debounce_time) @(vif.cb);
  endtask : reset

  task automatic normal();
    vif.cb.sw_i <= 1'b1;
    repeat (debounce_time) @(vif.cb);
    vif.cb.sw_i <= 1'b0;
    repeat (debounce_time) @(vif.cb);
  endtask : normal

  task automatic bounce();
    int delay1, delay2;
    realtime time1, time2;
    for (int i = 0; i < 1000; i++) begin
      delay1 = $urandom_range(debounce_time / 10, debounce_time);
      delay2 = $urandom_range(debounce_time / 10, debounce_time);
      $display("[INFO] %4t: iter = %3d, delay1 = %10d, delay2 = %10d", $realtime, i, delay1,
               delay2);
      vif.cb.sw_i <= 1'b1;
      time1 = $realtime;
      repeat (delay1) @(vif.cb);
      vif.cb.sw_i <= 1'b0;
      time2 = $realtime;
      repeat (delay2) @(vif.cb);
      $display("[INFO] %4t: iter = %3d, time1  = %t, time2  = %t", $realtime, i, time1, time2);
    end
  endtask : bounce

  task automatic check_db_tick();
    int tick_counter = 0;
    int tick_error_counter = 0;
    forever begin

      fork
        begin : wd_timer_fork
          fork : db_tick_wd_timer
            begin
              wait (vif.cb.db_tick_o != 1);
              @(vif.cb iff (vif.cb.db_tick_o == 1));
              tick_counter++;
              $display("[INFO] %4t: posedge db_tick_o, num_pulses: %4d", $realtime, tick_counter);
            end
            begin
              repeat (10_000) @(vif.cb);
              $display("[INFO] %4t: Timed out!", $realtime);
              $display("[INFO] %4t: tick_counter: %4d, tick_error_counter: %4d", $realtime,
                       tick_counter, tick_error_counter);
              $finish;
            end
          join_any : db_tick_wd_timer
          disable fork;
        end : wd_timer_fork
      join

      @(vif.cb)
      if (vif.cb.db_tick_o == 1) begin
        tick_error_counter++;
        $display("[ERROR] %4t: db_tick_o ", $realtime);
        //$finish;
      end

    end
  endtask : check_db_tick

endmodule : test
