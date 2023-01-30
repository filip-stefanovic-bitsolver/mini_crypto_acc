
module dv_apb_mem_model #(
  parameter USE_MEM = 0
)( 
  input         clk,
  input         reset_n,
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
generate 
  if (USE_MEM != 0)
  begin : gen_dv_mem_model

  dv_mem_model #(
    .DW (16), 
    .AW (5)  
  ) dv_mem_model_i (
    .clk(clk),   //clock
    .we(penable && pwrite),    //write-enable, active high
    .addr(paddr[4:0]),  //address bus
    .din(pwdata),   //input data bus
    .dout(prdata)   //output data bus
  );

  assign pready = 1'b1;
  assign pslverr = 1'b0;

  end : gen_dv_mem_model
  else 
  begin : gen_random_implementation
    initial begin
      prdata = 16'hABCD;
      pready = 0;
      pslverr = 0;
    end
    always @(posedge clk)
    begin
      if (!penable)
        pslverr = $random;
      pready = $random;
    end 
  end : gen_random_implementation
endgenerate
endmodule

