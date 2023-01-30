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
  reg [15:0] result_w;
  reg result_en;
  

  function test (mem_adr, size);
  reg [19:0] mem_adr;
  reg size;
  reg [15:0] result_f;
  if (size) 
    result_f = result;
  else
    result_f = result_w;
    $display("read result: %16b", result_f);
    $display("data in mem: %16b", reference_rm_data[mem_adr]);
    if(result_f == reference_rm_data[mem_adr])
      $display("test passed");
    else
      $display("test not passed");
  endfunction

  spi_tb spi_tb();

  defparam spi_tb.apb_rm_i.USE_MEM = 1;
  
  initial begin
    result_en = 1;
    repeat (25) @(posedge spi_tb.clk);
    spi_tb.dv_spi_master_i.drive_dword(1,40,48'hccdf1745ad08,0,result);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha96b1704a7de,0,result);
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(2,40,48'ha978176fad08,1,result);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdead,1,result);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hffff,1,result);
    spi_tb.dv_spi_master_i.drive_word(2,40,16'hdaad,0,result);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,40,48'ha978172fad08,1,result);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'hdead,1,result);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'ha0a0,1,result);
    spi_tb.dv_spi_master_i.drive_word(4,40,16'h0010,0,result);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,80,48'hccdf1745ad01,,result);//write on addr h'5ad01
    reference_rm_data[20'h5ad01] = 16'hccdf; 
    #2ns;
    spi_tb.dv_spi_master_i.drive_dword(4,80,48'hccdf1705ad01,,result); // read from addr h'5ad01
    #6ns;
    test (20'h5ad01, 1);
    #10ns;
    spi_tb.dv_spi_master_i.drive_dword(4,80,48'ha9781765ad03,1,result);
    reference_rm_data[20'h5ad03] = 16'ha978; 
    spi_tb.dv_spi_master_i.drive_word(4,80,16'hdead,1,result);
    reference_rm_data[20'h5ad05] = 16'hdead; 
    spi_tb.dv_spi_master_i.drive_word(4,80,16'ha0a0,1,result);
    reference_rm_data[20'h5ad07] = 16'ha0a0; 
    spi_tb.dv_spi_master_i.drive_word(4,80,16'h0010,0,result); 
    reference_rm_data[20'h5ad09] = 16'h0010; 
    #6ns
    spi_tb.dv_spi_master_i.drive_dword(4,80,48'ha9781725ad03,1,result);
    test (20'h5ad03, 1);
    spi_tb.dv_spi_master_i.drive_word(4,80,16'hdead,1,result_w);
    test (20'h5ad05, 0);
    spi_tb.dv_spi_master_i.drive_word(4,80,16'ha0a0,1,result_w);
    test (20'h5ad07, 0);
    spi_tb.dv_spi_master_i.drive_word(4,80,16'h0010,1,result_w); 
    test (20'h5ad09, 0);
    #100;
    $finish;  
  end
  
  // initial $dumpvars;

endmodule