`timescale 1ns/1ps //must be first so it's inherited in the included files

`include "spi_tb.v"

module spi_regmap_test();

  initial 
  begin
    $dumpfile("waves.vcd");
    for (int i = 0; i < 32; i = i + 1)
        //$dumpvars(0, spi_tb.apb_rm_i.dv_mem_model_i.mem[i]);
    $dumpvars;
  end

  reg [15:0] reference_rm_data[2**20-1:0];

  spi_tb spi_tb();

  defparam spi_tb.apb_rm_i.USE_MEM = 1;
  
  initial begin
    repeat (25) @(posedge spi_tb.clk);
    spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1745ad08);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha96b1704a7de);
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha978176fad08,1);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdead);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hffff);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdaad);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'ha978172fad08,1);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'hdead);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'hffff);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'hdaad);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1745adbb);//write on addr h'5adbb
    reference_rm_data[20'h5adbb] = 16'hccdf; 
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1705adbb); // read from addr h'5adbb
    #100;
    $finish;
  end
  
  // initial $dumpvars;

endmodule