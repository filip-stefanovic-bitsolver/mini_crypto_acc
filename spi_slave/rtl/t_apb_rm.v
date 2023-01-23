module t_apb_rm ( input clk,
                  input reset_n,
                  input penable,
                  input [1:0] psel,
                  input [19:0] paddr,
                  input [15:0] pwdata,
                  input pwrite,
                  input [1:0] pstrb,
                 
                  output [15:0] prdata_rm,
                  output pready_rm,
                  output pslverr_rm
);

  initial begin
    prdata_rm = 16'hABCD;
    pready_rm = 0;
    pslverr_rm = 0;
  end
   always @(posedge lib_tb_i.clk)
  begin
    pready_rm = $random;
    pslverr_rm = $random;
  end 

endmodule
