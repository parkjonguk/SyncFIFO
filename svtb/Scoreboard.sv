class scoreboard #(int WIDTH=1,int DEPTH=1,int REGOUT=1);
   int no_trans;
   int err_trans;
   
   mailbox mon_mbx;
   bit [WIDTH-1:0] mem[DEPTH-1:0];
   bit             wr_ptr;
   bit             rd_ptr;

   function new(mailbox mon_mbx);
      this.mon_mbx = mon_mbx;
      this.no_trans =0;
      this.err_trans=0;
      foreach(mem[i])begin
         mem[i] = 8'hff;
      end
   endfunction // new

   function result();
      $display("T=%0t [SCOREBOARD] Transaction verify %0.d   Transaction With %0.d Error",$realtime,this.no_trans,this.err_trans);
   endfunction // result

   task run();
      transaction #(WIDTH,DEPTH,REGOUT) trans;
      forever begin
         mon_mbx.get(trans);
         if(trans.wr_en) begin
            mem[wr_ptr] = trans.wr_data;
            wr_ptr++;
            $display("T=%0t [SCOREBOARD] Write Operation wr_ptr=0x%0h wr_data=0x%0h",$realtime,this.wr_ptr,trans.wr_data);
         end
         else if(trans.rd_en) begin
            if(trans.rd_data ==mem[rd_ptr]) begin
               rd_ptr ++;
               $display("T=%0t [SCOREBOARD] Read Operation rd_ptr= 0x%0h rd_data =0x%0h",$realtime,this.rd_ptr,trans.rd_data);
            end
            else begin
              $display("[SCOREBARD] Error Read Operation ! rd_data = 0x%0h  ram[rd_ptr] = 0x%0h",trans.rd_data,mem[rd_ptr]);
               err_trans++;
            end
         end
         if(trans.full) begin
            $display("T=%0t [SCOREBOARD] FIFO is FULL !",$realtime);
         end
         if(trans.empty) begin
            $display("T=%0t [SCOREBOARD] FIFO is Emtpry !",$realtime);
         end
         no_trans++;
      end // forever begin
   endtask // run
endclass // scoreboard

   
      
    
