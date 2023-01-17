module clk_rst_generator #(
  parameter CLK_PERIOD_NS = 2, 
  parameter RST_DURATION_NS = 10
) (
  output reg clk,
  output reg rst_n
);

  initial begin
    clk <= 1'b0;
    rst_n <= 1'b0;
    #(RST_DURATION_NS/1ns);   
    rst_n <= 1'b1;
  end          

  always begin 
    #(CLK_PERIOD_NS/2ns);    
    clk <= ~clk;
  end 

endmodule 