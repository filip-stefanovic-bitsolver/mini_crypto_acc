`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "spi_tb.v"

module spi_regmap_test();

 spi_tb spi_tb();

  initial begin
    repeat (25) @(posedge spi_tb.clk);
    spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1745ad08);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha96b1704a7de);
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha97817f7ad08,1);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdead);
    #100;
    $finish;
  end
  
  // initial $dumpvars;
  initial 
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end

endmodule