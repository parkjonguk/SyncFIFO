`define MONITOR_IF vif.MONITOR.monitor_cb

class monitor #(int WIDTH=1, int DEPTH=1, int REGOUT =1 );
   virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif;
   mailbox mon_mbx;
   semaphore sema;
   int       no_trans;


   
   function new(virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif,mailbox mon_mbx);
      this.vif = vif;
      this.mon_mbx = mon_mbx;
      this.no_trans = 0;
      this.sema = new(1);
   endfunction // new

   task write();
      transaction #(WIDTH,DEPTH,REGOUT) trans;
      trans = new();
      forever begin
         this.sema.get(1);
         if(`MONITOR_IF.wr_en) begin
            trans.wr_en = `MONITOR_IF.wr_en;
            trans.wr_data = `MONITOR_IF.wr_data;
            trans.full = `MONITOR_IF.full;
            trans.empty = `MONITOR_IF.empty;
            $display("T=%0t [MONITOR] WRITE Operation wr_en = %0h wr_data = 0x%0h ",$realtime,trans.wr_en,trans.wr_data);
            this.mon_mbx.put(trans);
         end
         this.sema.put(2);
         @(posedge vif.MONITOR.clk);
      end // forever begin
   endtask // write

   task read();
      transaction #(WIDTH,DEPTH,REGOUT) trans;
      trans = new();
      forever begin
         this.sema.get(2);
         this.mon_mbx.get(trans);
         if(`MONITOR_IF.rd_en) begin
            trans.rd_en =`MONITOR_IF.rd_en;
            @(posedge vif.MONITOR.clk);
            trans.rd_data = `MONITOR_IF.rd_data;
            trans.full = `MONITOR_IF.full;
            trans.empty = `MONITOR_IF.empty;
            $display("T=%0t [MONITOR] READ Operation rd_en = %0h rd_data = 0x%0h full = %0h empty = %0h",$realtime, trans.rd_en,trans.rd_data,trans.full,trans.empty);
         end
         this.no_trans++;
         this.mon_mbx.put(trans);
         this.sema.put(1);
      end // forever begin
   endtask // read

   task run();
      @(posedge vif.MONITOR.clk);
      fork
         write();
         read();
      join
   endtask // run
   
endclass // monitor

         
