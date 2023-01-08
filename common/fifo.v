module fifo(
  // Outputs
  dout, fill_level, full, empty,
  // Inputs
  clk, srst_n, push, pop, din
);
   
  parameter DW = 8;
  parameter AW = 4;
      
  localparam DEPTH = 2**AW;

  input           clk;
  input 	        srst_n;
  input 	        push;
  input 	        pop;
  input [DW-1:0]  din;
   
  output [DW-1:0] dout;
  output [AW  :0] fill_level;
  output 	        full;
  output 	        empty;

  logic [AW  :0]  wr_ptr;
  logic [AW  :0]  rd_ptr;
  logic 	        unused_overflow_of_subtract;
   
  always_ff @(posedge clk)
    if (~srst_n) begin
	    wr_ptr <= {AW+1{1'b0}};
	    rd_ptr <= {AW+1{1'b0}};
    end
    else if (push & pop) begin
	    wr_ptr <= (wr_ptr == '1) ? {AW+1{1'b0}} : (wr_ptr + {{AW{1'b0}}, 1'b1});
	    rd_ptr <= (rd_ptr == '1) ? {AW+1{1'b0}} : (rd_ptr + {{AW{1'b0}}, 1'b1});
    end
    else if (push & ~pop) begin
	    wr_ptr <= (wr_ptr == '1) ? {AW+1{1'b0}} : (wr_ptr + {{AW{1'b0}}, 1'b1});
    end
    else if (pop) begin
      rd_ptr <= (rd_ptr == '1) ? {AW+1{1'b0}} : (rd_ptr + {{AW{1'b0}}, 1'b1});
    end

  ff_mem #(
    .DW(DW),
    .AW(AW)
  ) ff_mem_i (
    // Inputs
    .clk    (clk), 
    .din    (din), 
    .wr_en  (push), 
    .wr_addr(wr_ptr[AW-1:0]), 
    .rd_addr(rd_ptr[AW-1:0]),
    // Outputs
    .dout   (dout)
  );

  assign empty      = (rd_ptr == wr_ptr);
  assign full       = ({~rd_ptr[AW], rd_ptr[AW-1:0]} == wr_ptr[AW:0]);
  assign fill_level = {(wr_ptr[AW] != rd_ptr[AW]), wr_ptr[AW-1:0]} - {1'b0, rd_ptr[AW-1:0]};
   
endmodule