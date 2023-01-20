`timescale 1ns/1ps

module secure_fsm_tb();

  reg clk;
  reg reset_n;
  reg [1:0] psel_s;
  reg penable_s;
  reg pwrite_s;
  reg [1:0] pstrb_s;
  reg [19:0] paddr_s;
  reg [15:0] pwdata_s;
  reg [15:0] prdata_rm;
  reg pready_rm;
  reg pslverr_rm;
  reg [15:0] prdata_icn;
  reg pready_icn;
  reg pslverr_icn;

  always begin
    #2ns;
    clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  initial begin
    clk = 0;
    reset_n = 0;
    pslverr_icn = 0;
    pslverr_rm = 0;
    pready_rm = 0;
    pready_icn = 0;
    psel_s = 2'b00;
    penable_s = 0;
    pwrite_s = 0;
    paddr_s = 20'h00000;
    pwdata_s = 16'h0000;
    prdata_icn = 16'h0000;
    prdata_rm = 16'h0000;
    #12ns;

    reset_n = 1;
    #6.01ns;

    //write rm - locked
    psel_s = 2'b01;
    pwrite_s = 1'b1;
    paddr_s = 20'h00123;
    pwdata_s = 16'h9432;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #20ns;

    pready_rm = 1;
    #4ns;

    psel_s = 2'b00;
    penable_s = 1'b0;
    pready_rm = 0;
    #12ns;

    //write icn - locked
    psel_s = 2'b10;
    pwrite_s = 1'b1;
    paddr_s = 20'h0B00A;
    pwdata_s = 16'h9432;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #4ns;

    psel_s = 2'b00;
    penable_s = 0;
    #20ns;

    //write icn pw - locked
    psel_s = 2'b10;
    pwrite_s = 1'b1;
    paddr_s = 20'h00C1A;
    pwdata_s = 16'hA007;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #4ns;

    psel_s = 0;
    penable_s = 0;
    #20ns;

    //read rm - unlocked
    psel_s = 2'b01;
    pwrite_s = 1'b0;
    paddr_s = 20'h00332;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #20ns;

    pready_rm = 1;
    prdata_rm = 16'h1FA2;
    #4ns;

    psel_s = 2'b00;
    penable_s = 1'b0;
    pready_rm = 0;
    prdata_rm = 0;
    #12ns;

    //read icn - unlocked
    psel_s = 2'b10;
    pwrite_s = 1'b0;
    paddr_s = 20'h00111;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #20ns;

    pready_rm = 1;
    prdata_rm = 16'h0E33;
    #4ns;

    psel_s = 2'b00;
    penable_s = 1'b0;
    pready_rm = 0;
    prdata_rm = 0;
    #12ns;

    //write icn pw - locked
    psel_s = 2'b10;
    pwrite_s = 1'b1;
    paddr_s = 20'h00C1A;
    pwdata_s = 16'hA007;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #4ns;

    psel_s = 0;
    penable_s = 0;
    #20ns;

    //read icn - locked
    psel_s = 2'b10;
    pwrite_s = 1'b0;
    paddr_s = 20'h00111;
    pstrb_s = 2'b11;
    #4ns;

    penable_s = 1'b1;
    #4ns;
    psel_s = 0;
    penable_s = 0;
    #20ns;

    #40ns;
    $finish;
  end

  secure_fsm secure_fsm (
    .clk(clk),
    .reset_n(reset_n),
    .psel_s(psel_s),
    .penable_s(penable_s),
    .pwrite_s(pwrite_s),
    .pstrb_s(pstrb_s),
    .paddr_s(paddr_s),
    .pwdata_s(pwdata_s),
    .prdata_rm(prdata_rm),
    .pready_rm(pready_rm),
    .pslverr_rm(pslverr_rm),
    .prdata_icn(prdata_icn),
    .pready_icn(pready_icn),
    .pslverr_icn(pslverr_icn)
  );
endmodule