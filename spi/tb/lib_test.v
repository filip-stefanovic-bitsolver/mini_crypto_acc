`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "lib_tb.v"

module lib_trial_test();

  byte spi_wdata[];
  byte spi_rdata[];

  initial begin
    spi_wdata = new [6];
    spi_wdata = '{1,2,4,8,0,0};
    repeat (25) @(posedge lib_tb_i.clk);
    lib_tb_i.t_spi_master_i.drive(1,5,spi_wdata);
    #10ns;
    lib_tb_i.t_spi_master_i.drive(2,5,spi_wdata);
    #2ns;
    lib_tb_i.t_spi_master_i.drive(4,5,spi_wdata);
    #100;
    $finish;
  end
  
  initial $dumpvars;

endmodule