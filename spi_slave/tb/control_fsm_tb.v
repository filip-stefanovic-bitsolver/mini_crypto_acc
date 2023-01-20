`timescale 1ns/1ps

module control_fsm_tb();
  
  reg clk;
  reg reset_n;
  reg address_ready;
  reg data_ready;
  reg [19:0] addr;
  reg [3:0] status;
  reg [15:0] wdata;
  reg pready_s;
  reg [15:0] prdata_s;
  reg pslverr_s_rm;
  reg pslverr_s_icn;
  reg cs_n;
  reg miso_start;

  always begin
    #2ns;
    clk = ~clk;
  end

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end

  initial begin
    clk = 0;
    reset_n = 0;
    pslverr_s_icn = 0;
    pslverr_s_rm = 0;
    cs_n = 0;
    prdata_s = 16'h0000;
    miso_start = 0;
    pslverr_s_rm = 0;
    pslverr_s_rm = 0;
    pready_s = 0;
    address_ready = 0;
    data_ready = 0;
    status = 4'h0;
    wdata = 16'h0000;
    addr = 20'h00000;
    #15ns;

    reset_n = 1;
    #27.01ns;

    //write rm
    address_ready = 1;
    addr = 20'h0208;
    status = 4'h4;
    #4ns;
    
    address_ready = 0;
    #20ns;

    data_ready = 1;
    wdata = 16'h1234;
    #4ns;
    data_ready = 0;
    #40ns;

    pready_s = 1;
    #4ns;
    pready_s = 0;
    #20ns;
    
    //write burst rm
    address_ready = 1;
    addr = 20'h1122;
    status = 4'h6;
    #4ns;
    
    address_ready = 0;
    #20ns;

    data_ready = 1;
    wdata = 16'h1234;
    #4ns;
    data_ready = 0;
    #40ns;

    pready_s = 1;
    #4ns;
    pready_s = 0;
    #20ns;

    data_ready = 1;
    wdata = 16'h1235;
    #4ns;
    data_ready = 0;
    #40ns;

    pready_s = 1;
    #4ns;
    pready_s = 0;
    #20ns;

    data_ready = 1;
    wdata = 16'h1236;
    #4ns;
    data_ready = 0;
    #40ns;
    
    pready_s = 1;
    #4ns;
    pready_s = 0;
    //#80ns;

    cs_n = 1;
    #4ns;

    cs_n = 0;
    #40ns;

    //read burst icn
    address_ready = 1;
    addr = 20'hA333;
    status = 4'h3;
    #4ns;
    
    address_ready = 0;
    #20ns;

    pready_s = 1;
    prdata_s = 16'hF0F1;
    #4ns;

    pready_s = 0;
    prdata_s = 16'h0000;
    #4ns;

    data_ready = 1;
    #4ns;
    data_ready = 0;
    #12ns;

    pready_s = 1;
    prdata_s = 16'hABC1;
    #4ns;

    pready_s = 0;
    prdata_s = 16'h0000;
    #12ns;

    data_ready = 1;
    #4ns;
    data_ready = 0;
    cs_n = 1;
    #12ns;
    cs_n = 0;
    #12ns;

    #40ns;
 
    //pslverr_icn write
    address_ready = 1;
    addr = 20'hBAAB;
    status = 4'h5;
    wdata = 16'h1111;
    #4ns;
    
    address_ready = 0;
    #20ns;
    data_ready = 1;
    #4ns;
    data_ready = 0;
    #12ns;

    pready_s = 1;
    pslverr_s_icn = 1;
    #4ns;

    pready_s = 0;
    pslverr_s_icn = 0;
    #12ns;

    data_ready = 1;
    #4ns;

    data_ready = 0;
    #20ns;

    //pslverr_rm burst read
    address_ready = 1;
    addr = 20'h0EEF;
    status = 4'h2;
    #4ns;

    address_ready = 0;
    #12ns;

    pready_s = 1;
    prdata_s = 16'hAAAA;
    #4ns;

    pready_s = 0;
    prdata_s = 16'h0000;
    //need 1 clk period?
    data_ready = 1;
    #4ns;

    data_ready = 0;
    #12ns;
    
    pready_s = 1;
    pslverr_s_rm = 1;
    prdata_s = 16'hABAB;
    #4ns;

    pready_s = 0;
    pslverr_s_rm = 0;
    #12ns;

    cs_n = 1;
    #4ns;

    cs_n = 0;
    data_ready = 1;
    #4ns;

    data_ready = 0;
    #40ns;

    //write rm reset
    address_ready = 1;
    addr = 20'h0208;
    status = 4'h4;
    #4ns;
    
    address_ready = 0;
    #20ns;

    data_ready = 1;
    reset_n = 0;
    wdata = 16'h1234;
    #4ns;
    data_ready = 0;
    #40ns;

    pready_s = 1;
    #4ns;
    pready_s = 0;
    #20ns;
    reset_n = 1;
    #40ns;

    //write icn
    address_ready = 1;
    addr = 20'h0208;
    status = 4'h3;
    #4ns;
    
    address_ready = 0;
    #20ns;

    miso_start = 1;
    pready_s = 1;
    #4ns;

    pready_s = 0;
    miso_start = 0;
    #40ns;

    #80ns;



    $finish;
    
    
  end

  control_fsm control_fsm (
    .clk(clk), 
    .reset_n(reset_n), 
    .address_ready(address_ready), 
    .data_ready(data_ready),
    .addr(addr), 
    .wdata(wdata), 
    .status(status),
    .pready_s(pready_s), 
    .prdata_s(prdata_s), 
    .pslverr_s_icn(pslverr_s_icn), 
    .pslverr_s_rm(pslverr_s_rm),
    .cs_n(cs_n),
    .miso_start(miso_start)
    );
  

endmodule