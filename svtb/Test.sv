`include "Environment.sv"
program automatic test(fifo_if vif);
   parameter WIDTH =8;
   parameter DEPTH =16;
   parameter REGOUT =1;
   
   environment #(.WIDTH(WIDTH),.DEPTH(DEPTH),.REGOUT(REGOUT)) env;

   initial begin
      env = new(vif);
      env.run();
      env.g0.repeat_count = 10;
   end
endprogram // test
   
