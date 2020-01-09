//`include "Interface.sv"
module svtb_top (/*AUTOARG*/ ) ;
   parameter WIDTH=8;
   parameter DEPTH=16;
   parameter REGOUT=1;

   bit clk,rst_n;
   bit clr;
   
   always #5 clk = ~clk;

   initial begin
      rst_n = 0;
      clr = 0;
      #10 rst_n =1;
   end

   fifo_if #(.WIDTH(WIDTH),.DEPTH(DEPTH),.REGOUT(REGOUT)) vif(clk,rst_n);
   test #(.WIDTH(WIDTH),.DEPTH(DEPTH),.REGOUT(REGOUT)) t1(vif);
   generic_fifo_sync DUT(.clk (clk),
                         .clr (clr),
            .rst_n (vif.rst_n),
            .wr_en(vif.wr_en),
            .rd_en(vif.rd_en),
            .wr_data(vif.wr_data),
            .rd_data(vif.rd_data),
            .full(vif.full),
            .empty(vif.empty)
            );
   
endmodule // svtb_top
