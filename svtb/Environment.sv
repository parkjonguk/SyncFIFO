`include "Transaction.sv"
`include "Generator.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Scoreboard.sv"

class environment #(int WIDTH=1, int DEPTH =1, int REGOUT =1);
   generator #(WIDTH,DEPTH,REGOUT) g0;
   driver    #(WIDTH,DEPTH,REGOUT) d0;
   monitor   #(WIDTH,DEPTH,REGOUT) m0;
   scoreboard #(WIDTH,DEPTH,REGOUT) s0;

   virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif;
   event   drv_done;
   mailbox drv_mbx;
   mailbox mon_mbx;

   function new(virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif);
      this.vif = vif; 
      drv_mbx = new();
      mon_mbx = new();

      g0 = new(drv_mbx,drv_done);
      d0 = new(vif, drv_mbx,drv_done);
      m0 = new(vif, mon_mbx);
      s0 = new(mon_mbx);
   endfunction // new

   task pre_test();
      d0.reset();
   endtask // pre_test
   
   task test();
      g0.run();
      d0.run();
      m0.run();
      s0.run();
   endtask // test

   task post_test();
      wait(g0.repeat_count == d0.no_trans);
      wait(g0.repeat_count == s0.no_trans);
   endtask // post_test

   task run();
      pre_test();
      test();
      post_test();
      $finish;
   endtask // run
endclass // environment

      
 
      
