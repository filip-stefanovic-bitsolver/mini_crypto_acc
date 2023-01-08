module ff_mem #( 
  parameter DW = 8,
  parameter AW = 4
) (
  // Outputs
  output [DW-1:0] dout,
  // Inputs
  input           clk, 
  input [DW-1:0]  din,
  input           wr_en,
  input [AW-1:0]  wr_addr,
  input [AW-1:0]  rd_addr
);

  localparam DEPTH = 2**AW;

  logic [DW-1:0] mem [DEPTH];

  assign dout = mem[rd_addr];

  always @(posedge clk)
    if (wr_en)
      mem[wr_addr] <= din;
      
endmodule