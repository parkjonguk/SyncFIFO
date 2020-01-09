interface fifo_if(input logic clk,rst_n);
   parameter WIDTH =8;
   parameter DEPTH =1;
   parameter REGOUT =1;

   logic             wr_en;
   logic [WIDTH-1:0] wr_data;

   logic             rd_en;
   logic [WIDTH-1:0] rd_data;
   logic             empty;
   logic             full;

   clocking driver_cb @(posedge clk or negedge rst_n);
      default input #1ns output #1ns;
      output         wr_en;
      output         wr_data;
      output         rd_en;
      input          empty;
      input          full;
      input          rd_data;
   endclocking:driver_cb;

   clocking monitor_cb @(posedge clk or negedge rst_n);
      default input #1ns output #1ns;
      input          wr_en;
      input          wr_data;
      input          rd_en;
      input          empty;
      input          full;
      input          rd_data;
   endclocking:monitor_cb;
   
   modport DRIVER (clocking driver_cb,input clk,rst_n);
   modport MONITOR (clocking monitor_cb,input clk,rst_n);
endinterface // fifo_if

 
