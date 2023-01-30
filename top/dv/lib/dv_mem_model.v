// define DUMP_MEMS to enable memory dumping
//`define DUMP_MEMS
module dv_mem_model #(
  parameter DW = 16, 
  parameter AW = 20 
) (
  input           clk,   //clock
  input           we,    //write-enable, active high
  input  [AW-1:0] addr,  //address bus
  input  [DW-1:0] din,   //input data bus
  output [DW-1:0] dout   //output data bus
);

  reg [DW-1:0][2**AW-1:0]mem;
  reg [DW-1:0] dout_q;
  
`ifdef DUMP_MEMS
`endif 

  always @(posedge clk)
    if (we) 
    begin
      mem[addr] <= din;
    end else 
    begin
      dout_q <= mem[addr];
    end
  assign  dout = dout_q;

endmodule