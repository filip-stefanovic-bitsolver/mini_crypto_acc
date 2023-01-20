module clk_reset_n_generator #(
  parameter CLK_PERIOD_NS = 10, 
  parameter RST_DURATION_NS = 50
) (
  output reg clk,
  output reg reset_n
);

  initial begin
    clk <= 1'b0;
    reset_n <= 1'b0;
    #(RST_DURATION_NS/1ns);   
    reset_n <= 1'b1;
  end          

  always begin 
    #(CLK_PERIOD_NS/2ns);    
    clk <= ~clk;
  end 

endmodule 