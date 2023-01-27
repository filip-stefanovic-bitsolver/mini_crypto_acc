`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "spi_tb.v"

module spi_regmap_test();

 spi_tb spi_tb();

  initial begin
    repeat (25) @(posedge spi_tb.clk);
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'habcd0052329f,0);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha00700500c1a,0);
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'hf97817f7ad08,1);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdead,1);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'h1234,0);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'h00000112322,0);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'h00000339888,1);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'h1234,1);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'h4321,0);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha00700500c1a,0);
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'h00000112322,0);
    #100ns;
    $finish;
  end
  
  // initial $dumpvars;
  initial 
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end

endmodule