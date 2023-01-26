`include "clk_rst_generator.v"
`include "dv_apb_mem_model.v"
`include "dv_mem_model.v"
`include "dv_spi_master.v"
`include "spi_slave.v"

module spi_tb ();

reg clk;
reg reset_n;
reg [15:0] prdata_rm;
reg pready_rm;
reg pslverr_rm;
reg [15:0] prdata_icn;
reg pready_icn;
reg pslverr_icn;
wire [1:0] psel;
wire [19:0] paddr;
wire [15:0] pwdata;
//wire [15:0] rdata;
//wire [3:0] status;
wire [15:0] prdata_s;
wire [15:0] prdata;
//wire [1:0] psel_s;
wire [1:0] pstrb;
//wire [19:0] paddr_s;
//wire [15:0] pwdata_s;
wire [3:0] mosi;
wire [3:0] miso;
wire [1:0] spi_mode;


clk_rst_generator clk_rst_generator_i (
  .clk(clk), 
  .reset_n(reset_n)
);

dv_apb_mem_model apb_rm_i(
  .clk(clk),
  .reset_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_rm),
  .pready(pready_rm),
  .pslverr(pslverr_rm)
);  

dv_apb_mem_model apb_icn_i(
  .clk(clk),
  .reset_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_icn),
  .pready(pready_icn),
  .pslverr(pslverr_icn)
);  

dv_spi_master dv_spi_master_i (
  .mosi(mosi),
  .miso(miso),
  .sclk(sclk),
  .cs_n(cs_n),
  .spi_mode(spi_mode)
);


//dv_mem_model dv_mem_model_i  (
//  .clk(clk),   //clock
//  .we(pwrite),    //write-enable, active high
//  .addr(paddr),  //address bus
//  .din(pwdata),   //input data bus
//  .dout(prdata)   //output data bus
//);


spi_slave spi_slave_i ( 
  .clk(clk),
  .reset_n(reset_n),
  .sclk(sclk),
  .cs_n(cs_n),
  .mosi(mosi),
  .spi_mode(spi_mode),
  .prdata_rm(prdata_rm),
  .pready_rm(pready_rm),
  .pslverr_rm(pslverr_rm),
  .prdata_icn(prdata_icn),
  .pready_icn(pready_icn),
  .pslverr_icn(pslverr_icn),

  .miso(miso),
  .psel(psel),
  .penable(penable),
  .pwrite(pwrite),
  .pstrb(pstrb),
  .paddr(paddr),
  .pwdata(pwdata),
  .err(err)
);

endmodule