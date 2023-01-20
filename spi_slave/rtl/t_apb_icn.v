module t_apb_icn ( input clk,
                  input reset_n,
                  input penable,
                  input [1:0] psel,
                  input [19:0] paddr,
                  input [15:0] pwdata,
                  input pwrite,
                  input [1:0] pstrb,
                 
                  output [15:0] prdata_icn,
                  output pready_icn,
                  output pslverr_icn
);

  initial begin
    prdata_icn = 16'hABCD;
    pready_icn = 0;
    pslverr_icn = 0;
  end

   always @(posedge lib_tb_i.clk)
  begin
    pready_icn = $random;
    pslverr_icn = $random;
  end 

endmodule
