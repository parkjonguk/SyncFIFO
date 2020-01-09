module generic_fifo_sync (/*AUTOARG*/
   // Outputs
   rd_data, empty, full,
   // Inputs
   clk, rst_n, clr, wr_en, wr_data, rd_en
   ) ;
   parameter  WIDTH      = 8;
   parameter  DEPTH      = 16;
   parameter  REGOUT     = 1;

   localparam PTR_W      = $clog2(DEPTH - 1);

   // Synchronous clock with asynchronous reset
   input                clk;
   input                rst_n;

   // Flush port
   input                clr;

   // Write channel
   input                wr_en;
   input  [WIDTH-1:0]   wr_data;

   // Read channel
   input                rd_en;
   output [WIDTH-1:0]   rd_data;

   // Status channel
   output               empty;
   output               full;


   // Output type
   reg [WIDTH-1:0]      rd_data;

   wire                 empty;
   wire                 full;


   // Internal Register
   reg [WIDTH-1:0]      mem [0:(DEPTH-1)];
   reg [PTR_W-1:0]      rd_ptr;
   reg                  rd_flag;
   reg [PTR_W-1:0]      wr_ptr;
   reg                  wr_flag;


   // Status signal
   wire   ptr_match;
   assign ptr_match   = (rd_ptr == wr_ptr);

   assign full        = ptr_match &  (rd_flag ^ wr_flag);
   assign empty       = ptr_match & !(rd_flag ^ wr_flag);

   // Write pointer control
   wire                 wr_ptr_incr;
   wire                 wr_ptr_over;
   wire [PTR_W-1:0]     wr_ptr_add1;
   wire [PTR_W-1:0]     wr_ptr_next;

   assign wr_ptr_incr = wr_en & ~full;
   assign wr_ptr_over = (wr_ptr == $unsigned(DEPTH-1));
   assign wr_ptr_add1 = wr_ptr + {{(PTR_W-1){1'b0}}, 1'b1};
   assign wr_ptr_next = wr_ptr_over ? {(PTR_W){1'b0}} : wr_ptr_add1;

   // Read pointer control
   wire                 wr_ptr_incr;
   wire                 rd_ptr_incr;
   wire                 rd_ptr_over;
   wire [PTR_W-1:0]     rd_ptr_add1;
   wire [PTR_W-1:0]     rd_ptr_next;

   assign rd_ptr_incr = rd_en & ~empty;
   assign rd_ptr_over = (rd_ptr == $unsigned(DEPTH-1));
   assign rd_ptr_add1 = rd_ptr + {{(PTR_W-1){1'b0}}, 1'b1};
   assign rd_ptr_next = rd_ptr_over ? {(PTR_W){1'b0}} : rd_ptr_add1;

   // Write Pointer Register
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         wr_flag <= 1'b0;
         wr_ptr  <= {PTR_W{1'b0}};
      end else begin
         if(clr) begin
            wr_flag <= 1'b0;
            wr_ptr <= {PTR_W{1'b0}};
         end else if(wr_ptr_incr) begin
            wr_flag <= wr_flag ^ wr_ptr_over;
            wr_ptr  <= wr_ptr_next;
         end
      end
   end

   // Read Pointer Register
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rd_flag <= 1'b0;
        rd_ptr <= {PTR_W{1'b0}};
      end else begin
         if(clr) begin
            rd_flag <= 1'b0;
            rd_ptr <= {PTR_W{1'b0}};
         end else if(rd_ptr_incr) begin
            rd_flag <= rd_flag ^ rd_ptr_over;
            rd_ptr  <= rd_ptr_next;
         end
      end
   end

   // Write data to memory
   always @ (posedge clk) begin
      if(wr_ptr_incr) begin
         mem[wr_ptr] <= wr_data;
      end
   end

   // Read Data Register
   generate
      if (REGOUT == 1) begin : RegGen
         always @ (posedge clk or negedge rst_n) begin
            if(!rst_n)begin
               rd_data <= {WIDTH{1'b0}};
            end else begin
               if(clr) begin
                  rd_data <= {WIDTH{1'b0}};
               end else if(rd_ptr_incr) begin
                  rd_data <= mem[rd_ptr];
               end
            end
         end
      end else begin : MuxGen
         always @ (*) begin
            rd_data = mem[rd_ptr];
         end
      end
   endgenerate

endmodule // fifo
