`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "spi_tb.v"

module lib_test();

 spi_tb spi_tb();

  initial begin
    repeat (25) @(posedge spi_tb.clk);
    spi_tb.t_spi_master_i.drive_dword(1,5,32'h17f3ad08);
    #10ns;
    spi_tb.t_spi_master_i.drive_dword(2,5,32'h17f3ad08);
    #2ns;
    spi_tb.t_spi_master_i.drive_dword(4,5,32'h17f3ad08,1);
    spi_tb.t_spi_master_i.drive_word(4,10,16'hdead);
    #100;
    $finish;
  end
  
  initial $dumpvars;
  //initial 
  // begin
  //   $dumpfile("waves.vcd");
  //   $dumpvars;
  // end

endmodule