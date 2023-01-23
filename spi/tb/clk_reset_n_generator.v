`timescale 1ns/1ps
module clk_reset_n_generator //#(
  //parameter CLK_PERIOD_NS = 10, 
  //parameter RST_DURATION_NS = 50
//) 
(
  output reg clk,
  output reg reset_n
);

  initial begin
    clk <= 1'b0;
    reset_n <= 1'b0;
    #50;   
    reset_n <= 1'b1;
  end          

  always begin 
    #5;    
    clk <= ~clk;
  end 

endmodule 