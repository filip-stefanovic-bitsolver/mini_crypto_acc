`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "lib_tb.v"

module lib_test();
 lib_tb lib_tb_i();
  initial begin
    repeat (25) @(posedge lib_tb_i.clk);
    lib_tb_i.t_spi_master_i.drive_dword(1,5,32'h17f3ad08);
    #10ns;
    lib_tb_i.t_spi_master_i.drive_dword(2,5,32'h17f3ad08);
    #2ns;
    lib_tb_i.t_spi_master_i.drive_dword(4,5,32'h17f3ad08,1);
    lib_tb_i.t_spi_master_i.drive_word(4,10,16'hdead);
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