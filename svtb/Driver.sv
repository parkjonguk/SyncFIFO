`define DRIVER_IF vif.DRIVER.driver_cb

class driver #(int WIDTH =1,int DEPTH =1,int REGOUT =1);
   virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif;
   mailbox drv_mbx;
   event   drv_done;
   int     no_trans;

   function new(virtual fifo_if #(WIDTH,DEPTH,REGOUT) vif,mailbox drv_mbx,event drv_done);
      this.vif = vif;
      this.drv_mbx = drv_mbx;
      this.drv_done = drv_done;
      
   endfunction // new

   task reset();
      $display("T=%0t [DRIVER] RESET Interface Signal ",$realtime);
      wait(!vif.rst_n);
      `DRIVER_IF.wr_en <=0;
      `DRIVER_IF.rd_en <=0;
      `DRIVER_IF.wr_data <={DEPTH{1'b0}};
      wait(vif.rst_n);
      $display("T=%0t [DRIVER] DONE RESET Interface Signal ",$realtime);
   endtask // reset

   task drive();
      forever begin
         transaction trans;
         drv_mbx.get(trans);
         `DRIVER_IF.wr_en <=0;
         `DRIVER_IF.rd_en <=0;
         drv_mbx.get(trans);
         $display("no: of transaction = %0h",no_trans);

         @(posedge vif.DRIVER.clk);
         if(trans.wr_en)begin
            `DRIVER_IF.wr_en <= trans.wr_en;
            `DRIVER_IF.wr_data <=trans.wr_data;
            trans.full <= `DRIVER_IF.full;
            trans.empty <= `DRIVER_IF.empty;
            $display("T=%0t [DRIVER] Write Mode  wr_en =%0h  wr_data = 0x%0h",$time,trans.wr_en,trans.wr_data);
         end

         if(trans.rd_en)begin
            `DRIVER_IF.rd_en <= trans.rd_en;
            @(posedge vif.DRIVER.clk);
            `DRIVER_IF.rd_en <= 0;
            @(posedge vif.DRIVER.clk);
            trans.rd_data <= `DRIVER_IF.rd_data;
            trans.full <=`DRIVER_IF.full;
            trans.empty <= `DRIVER_IF.empty;

            $display("T=%0t [DRIVER] Read Mode rd_en =%0h rd_data = 0x%0h",$time,trans.rd_en,trans.rd_data);
         end // if (trans.rd_en)
         no_trans++;
         ->drv_done;
      end // forever begin
   endtask // drive

   task run();
     forever begin
        fork
           begin
              wait(!vif.rst_n);
           end
           begin
              drive();

           end
        join_any
        disable fork;
     end // forever begin
   endtask // run
endclass // driver

            
         
         
