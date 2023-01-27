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
  reg [15:0] result;
  reg result_en;

  spi_tb spi_tb();

  defparam spi_tb.apb_rm_i.USE_MEM = 1;
  
  initial begin
    result_en = 1;
    repeat (25) @(posedge spi_tb.clk);
    // spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1745ad08,,1,result);
    // #10ns;
    // spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha96b1704a7de,,1,result);
    // #2ns;
    // spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha978176fad08,1,1,result);
    // spi_tb.dv_spi_master_i.drive_word(2,40,16'hdead,,1,result);
    // spi_tb.dv_spi_master_i.drive_word(2,40,16'hffff,,1,result);
    // spi_tb.dv_spi_master_i.drive_word(2,40,16'hdaad,,1,result);
    // #10ns;
    // spi_tb.dv_spi_master_i.drive_dword(4,40,48'ha978172fad08,1,1,result);
    // spi_tb.dv_spi_master_i.drive_word(4,40,16'hdead,,1,result);
    // spi_tb.dv_spi_master_i.drive_word(4,40,16'ha0a0,,1,result);
    // spi_tb.dv_spi_master_i.drive_word(4,40,16'h0010,,1,result);
    // #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'hccdf1745ad01,,result);//write on addr h'5adbb
    reference_rm_data[20'h5ad01] = 16'hccdf; 
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'hccdf1705ad01,,result); // read from addr h'5adbb
    #5ns;
    $display("%16b",result);
    $display("%16b",reference_rm_data[20'h5ad01]);
    if(result == reference_rm_data[20'h5ad01])
      $display("test passed");
    else
      $display("test not passed");
    #100;
    $finish;  
  end
  
  // initial $dumpvars;

endmodule