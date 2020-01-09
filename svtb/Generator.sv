class generator #(int WIDTH=1,int DEPTH=1,int REGOUT=1);
   rand transaction #(WIDTH,DEPTH,REGOUT) trans;
   mailbox drv_mbx;
   event   drv_done;
   int     repeat_count;

   function new(mailbox drv_mbx, event drv_done);
      this.drv_mbx = drv_mbx;
      this.drv_done = drv_done;
   endfunction // new

   task run();
      repeat(repeat_count) begin
         trans = new();
         if(!trans.randomize()) $fatal("<Generator> trans randomization failed !!!");
         drv_mbx.put(trans);
      end
      @(drv_done);
      $display("T=%0t [GENERATOR] Done generator",$realtime);
      
   endtask // run
endclass // generator

      
         
