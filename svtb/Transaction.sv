class transaction #(int WIDTH =1, int DEPTH =1, int REGOUT =1);
   rand bit wr_en;
   rand bit rd_en;
   // rand bit clr; // 보류 
   rand bit [WIDTH-1:0] wr_data;
   bit [WIDTH-1:0] rd_data;
   bit             empty;
   bit             full;

   constraint wr_rd_en{wr_en != rd_en;};
   
   function display();
      $display("T=%0t [Transaction] Randomize -------------------------- ",$time);
      if(wr_en) $display("<Write> wr_en=0x%0h wr_data=0x%0h",wr_en,wr_data);
      if(rd_en) $display("<Read> rd_en=0x%0h,",rd_en);
      $display("T=%0t [Transaction] End Randomize ---------------------- ",$time);
   endfunction // display

   function transaction do_copy();
      transaction trans;
      trans = new();
      trans.wr_en = this.wr_en;
      trans.rd_en = this.rd_en;
      trans.wr_data = this.wr_data;
      return trans;
   endfunction // do_copy   

endclass // transaction
