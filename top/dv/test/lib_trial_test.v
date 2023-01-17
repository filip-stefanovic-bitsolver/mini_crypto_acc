`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "lib_trial_tb.v"

module lib_trial_test();

  reg pready;
  reg pslverr;

  lib_trial_tb lib_trial_tb_i(
    .pready(pready),
    .pslverr(pslverr)
  );

  logic [15:0] data_read;

  initial begin
    repeat (25) @(posedge lib_trial_tb_i.pclk);
    lib_trial_tb_i.apb_master_i.apb_write('h00,'hdead, 'b11, data_read);
    $display("pslverr is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_write('h1,'h4ead, 'b10, data_read);
    $display("pslverr is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_write('h2,'hzead, 'b01, data_read);
    $display("pslverr is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_write('h3,'hfeed, 'b00, data_read);
    $display("pslverr is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_read('h0, data_read);
    $display("prdata @'h0 is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_read('h1, data_read);
    $display("prdata @'h1 is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_read('h2, data_read);
    $display("prdata @'h2 is %x", data_read);
    lib_trial_tb_i.apb_master_i.apb_read('h3, data_read);
    $display("prdata @'h3 is %x", data_read);
    #100;
  end

  byte spi_wdata[];
  byte spi_rdata[];

  initial begin
    spi_wdata = new [4];
    spi_wdata = '{1,2,4,8};
    repeat (25) @(posedge lib_trial_tb_i.pclk);
    lib_trial_tb_i.dv_spi_master_i.drive(1,5,spi_wdata);
    #10ns;
    lib_trial_tb_i.dv_spi_master_i.drive(2,5,spi_wdata);
    #2ns;
    lib_trial_tb_i.dv_spi_master_i.drive(4,5,spi_wdata);
    #100;
    $finish;
  end

  initial begin
    pready = 0;
    pslverr = 0;
  end

  always @(posedge lib_trial_tb_i.pclk)
  begin
    pready = $random;
    pslverr = $random;
  end 


  initial $dumpvars;

endmodule