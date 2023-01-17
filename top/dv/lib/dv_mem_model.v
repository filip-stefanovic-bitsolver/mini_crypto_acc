
// define DUMP_MEMS to enable memory dumping

module dv_mem_model #(
  parameter DW = 32, 
  parameter AW = 6 
) (
  input           clk,   //clock
  input           cs,    //chip-select, active high
  input           we,    //write-enable, active high
  input  [DW-1:0] be,    //bit-enable, active high
  input  [AW-1:0] addr,  //address bus
  input  [DW-1:0] din,   //input data bus
  output [DW-1:0] dout   //output data bus
);

  logic [DW-1:0] mem[AW**2];
  logic [DW-1:0] dout_q;

`ifdef DUMP_MEMS
  initial begin    
    for (int i = 0; i < 32; i = i + 1)
        $dumpvars(0, mem[i]);
  end
`endif 

  always @(posedge clk)
    if (cs) begin
      if (we) begin
        for (int i = 0;i < DW;i++)
          if (be[i])
            mem[addr][i] <= din[i];
      end else begin
        dout_q <= mem[addr];
      end
    end

  assign #10ps dout = dout_q;

endmodule