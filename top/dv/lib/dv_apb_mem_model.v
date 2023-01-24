
module dv_apb_mem_model ( 
                  input clk,
                  input reset_n,
                  input         penable,
                  input [1:0]   psel,
                  input [19:0]  paddr,
                  input [15:0]  pwdata,
                  input         pwrite,
                  input [1:0]   pstrb,
                 
                  output reg [15:0] prdata,
                  output reg pready,
                  output reg pslverr
);

  initial begin
    prdata = 16'hABCD;
    pready = 0;
    pslverr = 0;
  end
   always @(posedge clk)
  begin
    pready = $random;
    pslverr = $random;
  end 

endmodule

